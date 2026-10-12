import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Item {
    id: root

    required property var windowControls
    implicitHeight: header.implicitHeight

    signal closeRequested

    DankWindowHeader {
        id: header
        anchors.fill: parent
        controls: root.windowControls
        title: ImageService.galleryMode ? "Gallery" : (ImageService.currentFileName || "DankView")
        showDivider: true
        onCloseRequested: root.closeRequested()
    }

    // Leading item: Back to Gallery button / App icon
    Row {
        id: leadingRow
        anchors.left: parent.left
        anchors.leftMargin: Style.spacingM
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.spacingS

        DankIconButton {
            visible: !ImageService.galleryMode
            iconName: "arrow_back"
            size: "s"
            variant: "standard"
            tooltipText: "Back to Gallery (Esc)"
            Accessible.name: "Back to Gallery"
            onClicked: ImageService.backToGallery()
        }

        DankIcon {
            visible: ImageService.galleryMode
            name: "image"
            size: Style.iconSizeSmall
            color: Style.primary
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
