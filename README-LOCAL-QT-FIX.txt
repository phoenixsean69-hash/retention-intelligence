Retention Intelligence - V0.4 Qt bridge crash fix

Issue observed: Windows access violation 0xC0000005 when QML accesses
DesktopBackend, while the original Backend passes the same Qt test.

Likely source: 21 subclass QML properties in DesktopBackend use the
inherited Backend.changed signal in their @Property(..., notify=...) declarations.

Correction: DesktopBackend now declares its own v04Changed signal and
forwards Backend.changed to it. All 21 new properties use the local signal.
No ML, UI, customer data, or settings changes are included.

This is a targeted candidate fix, not confirmed on Windows until you run it.

Apply to the root of your existing project, keeping a backup:
  Expand-Archive -Path "<zip path>" -DestinationPath . -Force

Check on Windows:
  .\.venv\Scripts\python.exe -m unittest tests.test_qt_bridge_contract -v
  .\.venv\Scripts\python.exe -u diagnose_startup.py
  .\.venv\Scripts\python.exe -u main.py --debug-startup

If the minimal v0.4 backend still crashes, stop and send the new diagnostic.
Do not push the patch until your Windows startup is working.
