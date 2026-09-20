import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

// Thin 3-column header matching DMS popup header pattern:
//   Left  — back nav + counter pill + zoom pill
//   Center — image filename (centered absolutely)
//   Right  — action buttons + expand + close
Item {
    id: root

    required property var windowControls
    implicitHeight: Math.max(buttons.implicitHeight, leftRow.implicitHeight) + Theme.spacingXS * 2

    signal closeRequested

    // Drag-to-move (whole header minus button area)
    MouseArea {
        anchors.left: parent.left
        anchors.right: buttons.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.rightMargin: Theme.spacingM
        enabled: root.windowControls !== null
        onPressed: root.windowControls.tryStartMove()
        onDoubleClicked: root.windowControls.tryToggleMaximize()
    }

    component WinBtn: DankActionButton {
        buttonSize: Theme.buttonHeightXXS
        iconSize: Theme.iconSizeSmall
        iconColor: Theme.surfaceText
    }

    // ── LEFT ──────────────────────────────────────────────────────────────────
    Row {
        id: leftRow
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingM
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingXS

        // Back to gallery / image-mode indicator
        DankActionButton {
            readonly property bool canGoBack: !ImageService.galleryMode
            iconName: canGoBack ? "arrow_back" : "image"
            iconSize: Theme.iconSizeSmall
            buttonSize: Theme.buttonHeightXXS
            enabled: canGoBack
            iconColor: canGoBack ? Theme.surfaceText : Theme.primary
            tooltipText: canGoBack ? "Back to Gallery (Esc)" : ""
            tooltipSide: "bottom"
            onClicked: {
                if (canGoBack)
                    ImageService.backToGallery();
            }
        }


        // Animated image playback pill
        Rectangle {
            visible: !ImageService.galleryMode && ImageService.isAnimated
            implicitHeight: Theme.buttonHeightXXS
            implicitWidth: playPauseRow.implicitWidth + Theme.spacingM * 2
            radius: height / 2
            color: playPauseMouse.containsMouse ? Theme.chipSurfaceNested : Theme.chipSurface
            anchors.verticalCenter: parent.verticalCenter

            RowLayout {
                id: playPauseRow
                anchors.centerIn: parent
                spacing: Theme.spacingXS

                DankIcon {
                    name: ImageService.isPlaying ? "pause" : "play_arrow"
                    size: Theme.iconSizeSmall
                    color: Theme.primary
                }

                StyledText {
                    text: ImageService.isPlaying ? "Pause" : "Play"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                }
            }

            MouseArea {
                id: playPauseMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ImageService.togglePlayback()
            }
        }
    }

    // ── CENTER — filename only, absolutely centered ────────────────────────────
    StyledText {
        id: centerTitle
        // Reserve space equal to the larger of left/right rows so title stays truly centered
        readonly property real reserve: Math.max(leftRow.implicitWidth + Theme.spacingM,
                                                 buttons.implicitWidth + Theme.spacingM)
        anchors.verticalCenter: parent.verticalCenter
        x: reserve
        width: parent.width - reserve * 2
        text: ImageService.galleryMode ? "Gallery" : (ImageService.currentFileName || "DankView")
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Theme.fontWeightMedium
        color: Theme.surfaceText
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle
        wrapMode: Text.NoWrap
    }

    // ── RIGHT ─────────────────────────────────────────────────────────────────
    Row {
        id: buttons
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingM
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingXS

        // Favorite
        WinBtn {
            visible: !ImageService.galleryMode && ImageService.currentFilePath !== ""
            readonly property bool isFav: ImageService.isFavorite(ImageService.currentFilePath)
            iconName: isFav ? "favorite" : "favorite_border"
            iconColor: isFav ? Theme.error : Theme.surfaceText
            tooltipText: isFav ? "Remove from Favorites (F)" : "Add to Favorites (F)"
            tooltipSide: "bottom"
            onClicked: ImageService.toggleFavorite(ImageService.currentFilePath)
        }

        // Image Info / EXIF
        WinBtn {
            visible: !ImageService.galleryMode && ImageService.currentFilePath !== ""
            iconName: "info"
            iconColor: ImageService.inspectorOpen ? Theme.primary : Theme.surfaceText
            tooltipText: "Image Info / EXIF (I)"
            tooltipSide: "bottom"
            onClicked: ImageService.toggleInspector()
        }

        // Lock UI / Zen View
        WinBtn {
            visible: !ImageService.galleryMode && ImageService.currentFilePath !== ""
            iconName: "lock_open"
            tooltipText: "Lock UI / Clean View (K)"
            tooltipSide: "bottom"
            onClicked: ImageService.toggleLockUI()
        }

        // Open File
        WinBtn {
            iconName: "folder_open"
            tooltipText: "Open Image (O / Ctrl+O)"
            tooltipSide: "bottom"
            onClicked: ImageService.openFileDialog()
        }

        // Divider
        Rectangle {
            implicitWidth: 1
            implicitHeight: Theme.iconSize
            color: Theme.withAlpha(Theme.outlineVariant, 0.4)
            anchors.verticalCenter: parent.verticalCenter
        }

        // Minimize
        WinBtn {
            visible: root.windowControls?.canMinimize ?? false
            iconName: "minimize"
            tooltipText: "Minimize"
            tooltipSide: "bottom"
            onClicked: root.windowControls.tryMinimize()
        }

        // Expand / Restore
        WinBtn {
            visible: root.windowControls?.canMaximize ?? false
            iconName: (root.windowControls?.targetWindow?.maximized ?? false) ? "fullscreen_exit" : "fullscreen"
            tooltipText: (root.windowControls?.targetWindow?.maximized ?? false) ? "Restore" : "Maximize"
            tooltipSide: "bottom"
            onClicked: root.windowControls.tryToggleMaximize()
        }

        // Close
        WinBtn {
            iconName: "close"
            tooltipText: "Close"
            tooltipSide: "bottom"
            onClicked: root.closeRequested()
        }
    }

    // Bottom divider
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.outlineVariant
        opacity: 0.5
    }
}
