import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

// Floating status chips anchored to canvas bottom-left.
// Auto-fades after `idleMs` ms of no zoom/navigate activity.
// Re-appears instantly on zoom change or image navigation.
Item {
    id: root

    readonly property int idleMs: 3000
    readonly property bool hasContent: ImageService.currentFilePath !== "" && !ImageService.galleryMode

    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.margins: 14
    width: chipRow.implicitWidth
    height: chipRow.implicitHeight
    visible: hasContent
    opacity: 0

    // ── Trigger show ──────────────────────────────────────────────────────────
    function show() {
        opacity = 1;
        fadeTimer.restart();
    }

    Connections {
        target: ImageService
        function onZoomChanged()         { root.show() }
        function onCurrentIndexChanged() { root.show() }
        function onCurrentFilePathChanged() { root.show() }
    }

    // Initial show when content appears
    onHasContentChanged: if (hasContent) root.show()

    // ── Fade timer ────────────────────────────────────────────────────────────
    Timer {
        id: fadeTimer
        interval: root.idleMs
        repeat: false
        onTriggered: root.opacity = 0
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.shortDuration
            easing.type: Theme.standardEasing
        }
    }

    // ── Chips ─────────────────────────────────────────────────────────────────
    Row {
        id: chipRow
        spacing: Theme.spacingXS

        // Counter chip "3 / 12"
        Rectangle {
            visible: ImageService.fileList.length > 0
            implicitHeight: 28
            implicitWidth: counterText.implicitWidth + Theme.spacingM * 2
            radius: height / 2
            color: Theme.withAlpha(Theme.chipSurface, 0.88)
            border.color: Theme.withAlpha(Theme.outlineVariant, 0.25)
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter

            StyledText {
                id: counterText
                anchors.centerIn: parent
                text: (ImageService.currentIndex + 1) + " / " + ImageService.fileList.length
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }
        }

        // Zoom chip — click to reset, scroll to zoom
        Rectangle {
            id: zoomChip
            implicitHeight: 28
            implicitWidth: zoomRow.implicitWidth + Theme.spacingM * 2
            radius: height / 2
            color: zoomMouse.containsMouse
                   ? Theme.withAlpha(Theme.chipSurfaceNested, 0.92)
                   : Theme.withAlpha(Theme.chipSurface, 0.88)
            border.color: Theme.withAlpha(Theme.outlineVariant, 0.25)
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: Theme.shorterDuration } }

            RowLayout {
                id: zoomRow
                anchors.centerIn: parent
                spacing: Theme.spacingXS

                DankIcon {
                    name: "zoom_in"
                    size: 14
                    color: Theme.surfaceVariantText
                }

                StyledText {
                    text: Math.round(ImageService.zoom * 100) + "%"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                }
            }

            MouseArea {
                id: zoomMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.fadeTimer.stop()
                onExited:  root.fadeTimer.restart()
                onClicked: {
                    ImageService.resetZoom();
                    root.show();
                }
                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0)
                        ImageService.zoomIn();
                    else
                        ImageService.zoomOut();
                }
            }

            DankTooltipHost {
                text: "Scroll to zoom • Click to reset"
                target: zoomChip
                hoverArea: zoomMouse
                side: "top"
            }
        }
    }
}
