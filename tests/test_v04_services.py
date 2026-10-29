import tempfile
import unittest
from pathlib import Path
import pandas as pd
from analytics_engine import quality_report, segmentation
from data_engine import CustomerDataset
from ml_engine import train_model
from retention_store import CaseStore
from report_engine import export_pdf, export_segments_csv


class ServiceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.ds = CustomerDataset.from_file(Path(__file__).parent.parent / 'sample_data' / 'DEMO_SYNTHETIC_telco_customers.csv')

    def test_segments_reconcile(self):
        segments = segmentation(self.ds,'Contract')
        self.assertEqual(sum(row['count'] for row in segments),self.ds.metrics['known'])
        self.assertEqual(sum(row['churned'] for row in segments),self.ds.metrics['churned'])
        self.assertEqual(quality_report(self.ds)['duplicateIds'],0)

    def test_training_and_ranking(self):
        model = train_model(self.ds)
        self.assertGreaterEqual(model.metrics['rocAuc'],0)
        self.assertLessEqual(model.metrics['rocAuc'],1)
        self.assertEqual(model.metrics['testRows'],45)
        ranked = model.predict(self.ds)
        self.assertEqual(len(ranked),self.ds.metrics['retained'])
        self.assertTrue(all(ranked[i]['probability'] >= ranked[i+1]['probability'] for i in range(len(ranked)-1)))
        self.assertFalse(any('churn' in c.lower() or 'customer' in c.lower() for c in model.feature_names))

    def test_duplicate_ids_fail_training(self):
        frame = self.ds.frame.copy()
        frame.loc[1,self.ds.mapping['customer_id']] = frame.loc[0,self.ds.mapping['customer_id']]
        dup = CustomerDataset(frame, self.ds.mapping, self.ds.file_name)
        with self.assertRaisesRegex(ValueError,'Duplicate customer IDs'):
            train_model(dup)

    def test_case_isolation(self):
        with tempfile.TemporaryDirectory() as td:
            store = CaseStore(Path(td)/'cases.sqlite')
            store.create('A','100','Review account','Follow up')
            self.assertEqual(len(store.list('A')),1)
            self.assertEqual(store.list('B'),[])
            case = store.list('A')[0]
            store.change_status('A',case['id'],'Contacted')
            self.assertEqual(store.list('A')[0]['status'],'Contacted')

    def test_report_files(self):
        with tempfile.TemporaryDirectory() as td:
            pdf=Path(td)/'report.pdf'
            csv=Path(td)/'segments.csv'
            export_pdf(pdf,self.ds)
            export_segments_csv(csv,self.ds)
            self.assertGreater(pdf.stat().st_size,500)
            self.assertGreater(csv.stat().st_size,100)
            self.assertEqual(pdf.read_bytes()[:4],b'%PDF')
            self.assertIn('dimension',pd.read_csv(csv).columns)


if __name__ == '__main__': unittest.main()
