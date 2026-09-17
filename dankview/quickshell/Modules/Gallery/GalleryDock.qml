import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Rectangle {
    id: root

    readonly property bool isSelectionMode: ImageService.gallerySelectedCount > 0

    implicitHeight: 46
    implicitWidth: (isSelectionMode ? selectionRow.implicitWidth : navRow.implicitWidth) + 24
    radius: 23
    color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, 0.95)
    border.color: isSelectionMode
        ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.40)
        : Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.28)
    border.width: 1
    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.shortDuration
            easing.type: Theme.standardEasing
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: Theme.shortDuration
        }
    }

    // Navigation Tabs (Shown when 0 images selected)
    RowLayout {
        id: navRow
        anchors.centerIn: parent
        spacing: 6
        visible: opacity > 0
        opacity: root.isSelectionMode ? 0.0 : 1.0
        scale: root.isSelectionMode ? 0.92 : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.shortDuration
                easing.type: Theme.standardEasing
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Theme.shortDuration
                easing.type: Theme.standardEasing
            }
        }

        Repeater {
            model: [
                { id: "gallery", label: "Gallery", icon: "photo_library" },
                { id: "albums",  label: "Albums",  icon: "collections_bookmark" }
            ]

            delegate: Rectangle {
                id: tabBtn
                readonly property bool isActive: ImageService.galleryTab === modelData.id
                implicitHeight: 38
                implicitWidth: 110
                radius: 19
                color: isActive ? Theme.primaryContainer : (tabMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent")

                Behavior on color { ColorAnimation { duration: Theme.shortDuration } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    DankIcon {
                        name: modelData.icon
                        size: 20
                        color: tabBtn.isActive ? Theme.primary : Theme.surfaceText
                    }

                    Text {
                        text: modelData.label
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall + 1
                        font.weight: tabBtn.isActive ? Font.DemiBold : Font.Normal
                        color: tabBtn.isActive ? Theme.primary : Theme.surfaceText
                    }
                }

                MouseArea {
                    id: tabMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ImageService.galleryTab = modelData.id
                }
            }
        }
    }

    // Selection Action Toolbar (Morphs in when 1 or more images are selected)
    RowLayout {
        id: selectionRow
        anchors.centerIn: parent
        spacing: 8
        visible: opacity > 0
        opacity: root.isSelectionMode ? 1.0 : 0.0
        scale: root.isSelectionMode ? 1.0 : 0.92

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.shortDuration
                easing.type: Theme.standardEasing
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Theme.shortDuration
                easing.type: Theme.standardEasing
            }
        }

        // Selected Count Badge + Dismiss Button
        Rectangle {
            implicitHeight: 34
            implicitWidth: countInner.implicitWidth + 16
            radius: 17
            color: Theme.primaryContainer

            RowLayout {
                id: countInner
                anchors.centerIn: parent
                spacing: 6

                DankIcon {
                    name: "check_circle"
                    size: 18
                    color: Theme.primary
                }

                Text {
                    text: ImageService.gallerySelectedCount + " selected"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                    color: Theme.primary
                }

                DankIcon {
                    name: "close"
                    size: 16
                    color: Theme.primary
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ImageService.clearSelection()
            }
        }

        // Thin Separator
        Rectangle {
            implicitWidth: 1
            implicitHeight: 20
            color: Theme.outlineVariant
            opacity: 0.35
        }

        // Action: Select All / Deselect All
        DankActionButton {
            iconName: ImageService.isAllSelected ? "deselect" : "select_all"
            iconSize: 18
            buttonSize: 34
            tooltipText: ImageService.isAllSelected ? "Deselect All (Ctrl+A)" : "Select All (Ctrl+A)"
            tooltipSide: "top"
            onClicked: ImageService.selectAll()
        }

        // Action: Favorite / Unfavorite Selected
        DankActionButton {
            iconName: "favorite"
            iconSize: 18
            buttonSize: 34
            tooltipText: "Favorite Selected"
            tooltipSide: "top"
            onClicked: ImageService.toggleFavoriteSelected()
        }

        // Action: Copy / Clipboard
        DankActionButton {
            iconName: "content_copy"
            iconSize: 18
            buttonSize: 34
            tooltipText: "Copy to Clipboard (Ctrl+C)"
            tooltipSide: "top"
            onClicked: ImageService.copySelectedFiles()
        }

        // Action: Open With
        DankActionButton {
            iconName: "open_in_new"
            iconSize: 18
            buttonSize: 34
            tooltipText: "Open With System App"
            tooltipSide: "top"
            onClicked: ImageService.openSelectedWith()
        }

        // Action: Delete / Move to Trash
        DankActionButton {
            iconName: "delete"
            iconSize: 18
            buttonSize: 34
            iconColor: Theme.error
            tooltipText: "Move to Trash (Delete)"
            tooltipSide: "top"
            onClicked: ImageService.trashSelected()
        }
    }
}
