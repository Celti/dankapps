import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

// Thin window header: centered title, action row + expand/close on the right.
// Matches the new DMS popup header pattern (DankWindowHeader).
DankWindowHeader {
    id: root

    required property var windowControls
    property var targetWindow: null

    controls: windowControls
    title: ImageService.galleryMode ? "Gallery — DankView" : (ImageService.currentFileName || "DankView")
    showDivider: true

    // Drag area is handled by DankWindowHeader's built-in MouseArea.
    // Extra actions injected into the right button row (before expand/close).

    // Animated image playback pill
    Rectangle {
        visible: !ImageService.galleryMode && ImageService.isAnimated
        implicitHeight: Theme.buttonHeightXXS
        implicitWidth: playPauseRow.implicitWidth + Theme.spacingM * 2
        radius: height / 2
        color: playPauseMouse.containsMouse ? Theme.chipSurfaceNested : Theme.chipSurface

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

    // Counter badge (e.g. "3 / 12")
    Rectangle {
        visible: !ImageService.galleryMode && ImageService.fileList.length > 0
        implicitHeight: Theme.buttonHeightXXS
        implicitWidth: counterText.implicitWidth + Theme.spacingM * 2
        radius: height / 2
        color: Theme.chipSurface

        StyledText {
            id: counterText
            anchors.centerIn: parent
            text: (ImageService.currentIndex + 1) + " / " + ImageService.fileList.length
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
        }
    }

    // Zoom pill (scroll to zoom, click to reset)
    Rectangle {
        id: zoomPill
        visible: !ImageService.galleryMode && ImageService.currentFilePath !== ""
        implicitHeight: Theme.buttonHeightXXS
        implicitWidth: zoomPillRow.implicitWidth + Theme.spacingM * 2
        radius: height / 2
        color: zoomMouse.containsMouse ? Theme.chipSurfaceNested : Theme.chipSurface
        border.color: Theme.withAlpha(Theme.outlineVariant, 0.25)
        border.width: 1

        RowLayout {
            id: zoomPillRow
            anchors.centerIn: parent
            spacing: Theme.spacingXS

            DankIcon {
                name: "zoom_in"
                size: 15
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
            onClicked: ImageService.resetZoom()
            onWheel: wheel => {
                if (wheel.angleDelta.y > 0)
                    ImageService.zoomIn();
                else if (wheel.angleDelta.y < 0)
                    ImageService.zoomOut();
            }
        }

        DankTooltipHost {
            text: "Scroll to zoom • Click to reset"
            target: zoomPill
            hoverArea: zoomMouse
            side: "bottom"
        }
    }

    // Divider before action buttons
    Rectangle {
        visible: !ImageService.galleryMode && ImageService.currentFilePath !== ""
        implicitWidth: 1
        implicitHeight: Theme.iconSize
        color: Theme.withAlpha(Theme.outlineVariant, 0.4)
    }

    // Back to gallery / leading nav (shown in viewer mode)
    DankActionButton {
        readonly property bool canGoBack: !ImageService.galleryMode
        visible: true
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

    // Favorite
    DankActionButton {
        visible: !ImageService.galleryMode && ImageService.currentFilePath !== ""
        readonly property bool isFav: ImageService.isFavorite(ImageService.currentFilePath)
        iconName: isFav ? "favorite" : "favorite_border"
        iconSize: Theme.iconSizeSmall
        buttonSize: Theme.buttonHeightXXS
        iconColor: isFav ? Theme.error : Theme.surfaceText
        tooltipText: isFav ? "Remove from Favorites (F)" : "Add to Favorites (F)"
        tooltipSide: "bottom"
        onClicked: ImageService.toggleFavorite(ImageService.currentFilePath)
    }

    // Image Info / EXIF
    DankActionButton {
        visible: !ImageService.galleryMode && ImageService.currentFilePath !== ""
        iconName: "info"
        iconSize: Theme.iconSizeSmall
        buttonSize: Theme.buttonHeightXXS
        iconColor: ImageService.inspectorOpen ? Theme.primary : Theme.surfaceText
        tooltipText: "Image Info / EXIF (I)"
        tooltipSide: "bottom"
        onClicked: ImageService.toggleInspector()
    }

    // Lock UI / Zen View
    DankActionButton {
        visible: !ImageService.galleryMode && ImageService.currentFilePath !== ""
        iconName: "lock_open"
        iconSize: Theme.iconSizeSmall
        buttonSize: Theme.buttonHeightXXS
        iconColor: Theme.surfaceText
        tooltipText: "Lock UI / Clean View (K)"
        tooltipSide: "bottom"
        onClicked: ImageService.toggleLockUI()
    }

    // Open File
    DankActionButton {
        iconName: "folder_open"
        iconSize: Theme.iconSizeSmall
        buttonSize: Theme.buttonHeightXXS
        iconColor: Theme.surfaceText
        tooltipText: "Open Image (O / Ctrl+O)"
        tooltipSide: "bottom"
        onClicked: ImageService.openFileDialog()
    }
}
