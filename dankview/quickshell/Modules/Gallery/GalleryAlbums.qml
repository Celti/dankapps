import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Item {
    id: root

    readonly property var allAlbums: (ImageService.galleryData && ImageService.galleryData.albums) ? ImageService.galleryData.albums : []
    readonly property var pinnedAlbums: [ImageService.favoritesAlbum].concat(allAlbums.filter(a => a.isPinned))
    readonly property var customAlbums: allAlbums.filter(a => !a.isPinned)

    DankFlickable {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.bottomMargin: 80
        contentHeight: albumsCol.implicitHeight + 40
        clip: true

        ColumnLayout {
            id: albumsCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.top: parent.top
            spacing: 28

            // Pinned Categories
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 14
                visible: root.pinnedAlbums.length > 0

                StyledText {
                    text: "Pinned Categories"
                    font.pixelSize: Theme.fontSizeMedium + 1
                    font.weight: Theme.fontWeightBold
                    color: Theme.surfaceText
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 16

                    Repeater {
                        model: root.pinnedAlbums

                        delegate: AlbumCard {
                            album: modelData
                            cardWidth: 176
                            previewHeight: 176
                        }
                    }
                }
            }

            // Custom Categories
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 14
                visible: root.customAlbums.length > 0

                StyledText {
                    text: "Custom Categories"
                    font.pixelSize: Theme.fontSizeMedium + 1
                    font.weight: Theme.fontWeightBold
                    color: Theme.surfaceText
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 16

                    Repeater {
                        model: root.customAlbums

                        delegate: AlbumCard {
                            album: modelData
                            cardWidth: 176
                            previewHeight: 176
                        }
                    }
                }
            }

            // Empty state if no albums
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                visible: root.allAlbums.length === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    DankIcon {
                        Layout.alignment: Qt.AlignHCenter
                        name: "folder_open"
                        size: 40
                        color: Theme.surfaceVariantText
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No albums found"
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Theme.fontWeightBold
                        color: Theme.surfaceText
                    }
                }
            }
        }
    }
}
