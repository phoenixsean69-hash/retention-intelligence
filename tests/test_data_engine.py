import tempfile
import unittest
from pathlib import Path
import pandas as pd
from data_engine import CustomerDataset


class DatasetTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.path = Path(self.temp.name) / "test.csv"
        pd.DataFrame({
            "customerID": ["A-01", "B-02", "C-03", "D-04"],
            "Churn": ["Yes", "No", "Yes", "Unknown"],
            "Contract": ["Month-to-month", "Two year", "Month-to-month", "Two year"],
            "MonthlyCharges": [80, 50, 120, 30],
            "tenure": [4, 24, 10, 6],
        }).to_csv(self.path, index=False)

    def tearDown(self):
        self.temp.cleanup()

    def test_metrics_and_unknown_labels(self):
        data = CustomerDataset.from_file(self.path)
        self.assertEqual(data.metrics["total"], 4)
        self.assertEqual(data.metrics["known"], 3)
        self.assertEqual(data.metrics["churned"], 2)
        self.assertAlmostEqual(data.metrics["rate"], 66.66666666, places=3)
        self.assertEqual(data.metrics["monthly_associated"], 200.0)

    def test_filter_and_pagination(self):
        data = CustomerDataset.from_file(self.path)
        self.assertEqual(len(data.subset(churn_filter="Retained")), 1)
        results, pages, total = data.preview(page_size=2, page=1)
        self.assertEqual(len(results), 2)
        self.assertEqual(pages, 2)
        self.assertEqual(total, 4)
        self.assertEqual(len(data.subset(query="A-")), 1)


if __name__ == "__main__":
    unittest.main()
