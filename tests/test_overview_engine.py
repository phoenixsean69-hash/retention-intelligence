import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from data_engine import CustomerDataset
from overview_engine import overview_metrics


class OverviewMetricsTests(unittest.TestCase):
    def test_real_dataset_aggregates(self):
        ds = CustomerDataset.from_file(Path(__file__).parent.parent / 'sample_data' / 'DEMO_SYNTHETIC_telco_customers.csv')
        result = overview_metrics(ds, [{'probability': 20}, {'probability': 65}, {'probability': 86}], 65)
        self.assertEqual(result['retainedPct'], 72.2)
        self.assertEqual(result['churnedPct'], 27.8)
        self.assertEqual(result['atRiskCount'], 2)
        self.assertEqual(result['atRiskPct'], 66.7)
        self.assertEqual(result['scoredCount'], 3)
        self.assertEqual(sum(r['count'] for r in result['riskBands']), 3)
        self.assertTrue(0 < result['churnChargePct'] < 100)

    def test_empty(self):
        result = overview_metrics(None)
        self.assertEqual(result['atRiskCount'], 0)
        self.assertEqual(result['riskBands'], [])


if __name__ == '__main__':
    unittest.main()
