import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Item {
    id: root

    implicitHeight: ImageService.galleryTab === "gallery" ? 44 : 0
    visible: ImageService.galleryTab === "gallery"

    Behavior on implicitHeight { NumberAnimation { duration: 150; easing.type: Theme.standardEasing } }

    // Category Filter Chips (Gallery tab only)
    Flickable {
        id: chipFlick
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 6
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        contentWidth: chipRow.implicitWidth
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        RowLayout {
            id: chipRow
                spacing: 8

                Repeater {
                    model: ImageService.galleryCategories

                    delegate: Rectangle {
                        readonly property bool isSelected: ImageService.selectedCategory === modelData
                        readonly property bool isFavChip: modelData === "Favorites"
                        implicitHeight: 32
                        implicitWidth: chipContent.implicitWidth + 24
                        radius: 8
                        color: isSelected
                            ? Theme.primaryContainer
                            : (chipMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh)
                        border.color: isSelected
                            ? (isFavChip ? Theme.error : Theme.primary)
                            : Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.28)
                        border.width: 1

                        RowLayout {
                            id: chipContent
                            anchors.centerIn: parent
                            spacing: 5

                            DankIcon {
                                visible: isFavChip
                                name: "favorite"
                                size: 14
                                color: isFavChip ? Theme.error : (isSelected ? Theme.primary : Theme.surfaceText)
                            }

                            Text {
                                text: modelData
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: isSelected ? Font.DemiBold : Font.Medium
                                color: isSelected ? Theme.primary : Theme.surfaceText
                            }

                            Text {
                                visible: isFavChip && ImageService.favoriteCount > 0
                                text: "(" + ImageService.favoriteCount + ")"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall - 1
                                font.weight: Font.Medium
                                color: isSelected ? Theme.primary : Theme.surfaceVariantText
                            }
                        }

                        MouseArea {
                            id: chipMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ImageService.selectedCategory = modelData
                        }
                    }
                }
            }
        }
    }
