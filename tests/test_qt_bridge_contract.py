"""Regression test for the V0.4 QObject/QML notification-signal contract.

Uses temporary app data so test runs cannot read or modify user customer files.
"""
import os
import tempfile
import unittest
from unittest.mock import patch

from backend_v04 import DesktopBackend


class QtBridgeSignalContractTests(unittest.TestCase):
    def test_subclass_properties_use_the_subclass_notify_signal(self):
        with tempfile.TemporaryDirectory(prefix="ri_signal_test_") as temporary_directory:
            with patch.dict(os.environ, {"LOCALAPPDATA": temporary_directory}):
                backend = DesktopBackend()
                meta = backend.metaObject()
                names = (
                    "modelReady", "modelTraining", "modelMessage", "modelMetrics",
                    "contractSegments", "riskCustomers", "retentionCases",
                    "dataQuality", "noticeText", "riskThreshold",
                )
                for name in names:
                    with self.subTest(property=name):
                        index = meta.indexOfProperty(name)
                        self.assertGreaterEqual(index, 0)
                        prop = meta.property(index)
                        self.assertTrue(prop.hasNotifySignal())
                        self.assertEqual(bytes(prop.notifySignal().name()), b"v04Changed")

                emitted = []
                backend.v04Changed.connect(lambda: emitted.append(True))
                backend.changed.emit()
                self.assertEqual(len(emitted), 1)


if __name__ == "__main__":
    unittest.main()
