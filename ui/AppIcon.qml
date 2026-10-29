import QtQuick

// Segoe MDL2 Assets is shipped with Windows 10 and Windows 11.
// Keep the mapping centralized instead of pasting private-use glyphs into pages.
Text {
    id: icon
    property string iconName: "overview"
    property int iconSize: 18
    readonly property var glyphMap: ({
        "overview": "E8A9",       // ViewAll
        "customers": "E716",      // People
        "analytics": "E9D2",      // AreaChart
        "prediction": "E99A",     // Robot
        "retention": "EA18",      // Shield
        "data": "E8B5",           // Import
        "model": "E9D9",          // Diagnostic
        "reports": "E9F9",        // ReportDocument
        "settings": "E713",       // Setting
        "search": "E721",         // Search
        "import": "E8B5",         // Import
        "download": "E896",       // Download
        "previous": "E72B",       // Back
        "next": "E72A",           // Forward
        "folder": "E838",         // FolderOpen
        "info": "EA1F",          // Info2
        "device": "E7F8",        // DeviceLaptopNoPic
        "filter": "E71C",        // Filter
        "alert": "E814",         // IncidentTriangle
        "people": "E716",        // People
        "pie": "EB05",           // PieSingle
        "money": "E8EF",         // Calculator
        "check": "E73E",         // CheckMark
        "list": "EA37",          // List
        "cloud": "E753"          // Cloud
    })
    text: String.fromCharCode(parseInt(glyphMap[iconName] || glyphMap["overview"], 16))
    font.family: "Segoe MDL2 Assets"
    font.pixelSize: iconSize
    font.weight: Font.Normal
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
    color: "#486581"
}
