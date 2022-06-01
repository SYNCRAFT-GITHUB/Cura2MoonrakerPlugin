import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import UM 1.5 as UM
import Cura 1.1 as Cura

Cura.MachineAction {

    UM.I18nCatalog { id: catalog; name: "cura" }

    id: base
    anchors.fill: parent
    
    property bool validUrl: true
    property bool validTranslation: true

    function outputFormat() {
        return outputFormatUfp.checked ? "ufp" : "gcode"
    }

    function updateConfig() {
        manager.saveConfig({
            url: urlField.text,
            api_key: apiKeyField.text,
            power_device: powerDeviceField.text,
            output_format: outputFormat(),
            upload_remember_state: uploadRememberStateBox.checked,
            upload_autohide_messagebox: uploadAutohideMessageboxBox.checked,
            trans_input: translateInputField.text,
            trans_output: translateOutputField.text,
            trans_remove: translateRemoveField.text,
            camera_url: cameraUrlField.text
        })
    }

    ListModel {
        id: tabNameModel

        Component.onCompleted: update()

        function update() {
            clear()
            append({ name: catalog.i18nc("@title:tab", "Connection") })
            append({ name: catalog.i18nc("@title:tab", "Upload") })
            append({ name: catalog.i18nc("@title:tab", "Monitor") })

        }
    }

    UM.Label {
        id: machineLabel

        anchors{
            top: parent.top
            left: parent.left        
            leftMargin: UM.Theme.getSize("default_margin").width
        }
        font: UM.Theme.getFont("large_bold")
        text: Cura.MachineManager.activeMachine.name
        horizontalAlignment: Text.AlignHCenter
    }

    UM.TabRow  {
        id: tabBar

        z: 5

        anchors {
            top: machineLabel.bottom
            topMargin: UM.Theme.getSize("default_margin").height
        }
        width: parent.width

        Repeater {
            model: tabNameModel
            delegate: UM.TabRowButton {
                checked: model.index == 0
                text: model.name
            }
        }
    }

    Cura.RoundedRectangle {
        id: tabView

        anchors {
            top: tabBar.bottom
            topMargin: -UM.Theme.getSize("default_lining").height
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        border {
            color: UM.Theme.getColor("lining")
            width: UM.Theme.getSize("default_lining").width
        }
        color: UM.Theme.getColor("main_background")
        radius: UM.Theme.getSize("default_radius").width
        cornerSide: Cura.RoundedRectangle.Direction.Down

        StackLayout {
            id: tabStack

            anchors.fill: parent
            currentIndex: tabBar.currentIndex

            Item {
                id: connectionPane

                RowLayout {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: UM.Theme.getSize("default_margin").width
                    }
                    spacing: UM.Theme.getSize("default_margin").width

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop

                        spacing: UM.Theme.getSize("default_margin").height

                        Item {
                            width: parent.width
                            height: 10
                        }
                        RowLayout {
                            width: parent.width
                            x: 15

                            UM.Label {
                                text: catalog.i18nc("@label", "Address (URL)")
                            }
                            UM.Label {
                                visible: !base.validUrl
                                leftPadding: 15
                                font: UM.Theme.getFont("default_italic")
                                color: UM.Theme.getColor("error")
                                text: catalog.i18nc("@error", "URL not valid. Example: http://192.168.1.2/")
                            }
                        }
                        Cura.TextField {
                            id: urlField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsUrl                 
                            maximumLength: 1024
                            onTextChanged: base.validUrl = manager.validUrl(urlField.text)
                            onEditingFinished: { updateConfig() }
                        }

                        Item {
                            width: parent.width
                            height: 10
                        }
                        UM.Label {
                            x: 15
                            text: catalog.i18nc("@label", "API-Key (Optional - if the network is untrusted)")
                        }
                        Cura.TextField {
                            id: apiKeyField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsApiKey
                            maximumLength: 1024
                            onEditingFinished: { updateConfig() }
                        }

                        Item {
                            width: parent.width
                            height: 10
                        }
                        UM.Label {
                            x: 15
                            text: catalog.i18nc("@label", "Power Device(s) (Name configured in moonraker.conf")
                        }
                        Cura.TextField {
                            id: powerDeviceField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsPowerDevice
                            maximumLength: 1024
                            onEditingFinished: { updateConfig() }
                        }
                    }
                }
            }
            
            Item {
                id: processPane

                RowLayout {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: UM.Theme.getSize("default_margin").width
                    }
                    spacing: UM.Theme.getSize("default_margin").width

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop

                        spacing: UM.Theme.getSize("default_margin").height

                        Item {
                         width: parent.width
                            height: 10
                        }
                        UM.Label {
                            x: 15
                            text: catalog.i18nc("@label", "Format")
                        }
                        ButtonGroup {
                            id: outputFormatValue
                        }
                        RowLayout {
                            x: 25

                            Cura.RadioButton {
                                ButtonGroup.group: outputFormatValue

                                id: outputFormatGcode

                                text: catalog.i18nc("@label", "G-code")
                                checked: manager.settingsOutputFormat != "ufp"
                                onClicked: { updateConfig() }
                            }
                            Cura.RadioButton {
                                ButtonGroup.group: outputFormatValue

                                id: outputFormatUfp

                                text: catalog.i18nc("@label", "UFP with Thumbnail")
                                checked: manager.settingsOutputFormat == "ufp"
                                onClicked: { updateConfig() }
                            }
                        }

        		        Item {
                            width: parent.width
                            height: 10
                        }
                        UM.Label {
                            x: 15
                            text: catalog.i18nc("@label", "Process")
                        }
                        UM.CheckBox {
                            id: uploadRememberStateBox

                            x: 25
                            text: catalog.i18nc("@label", "Remember state of \"Start print job\"")
                            checked: manager.settingsUploadRememberState
                            onClicked: { updateConfig() }
                        }
                        UM.CheckBox {
                            id: uploadAutohideMessageboxBox

                            x: 25
                            text: catalog.i18nc("@label", "Auto hide messagebox for successful upload (30 seconds)")
                            checked: manager.settingsUploadAutohideMessagebox
                        onClicked: { updateConfig() }
                        }

                        Item {
                            width: parent.width
                            height: 10
                        }
                        RowLayout {
                            x: 15

                            UM.Label {
                                text: catalog.i18nc("@label", "Filename Translation ")
                            }
                            UM.Label {
                                leftPadding: 25
                                font: UM.Theme.getFont("default_italic")
                                color: "gray"
                                text: catalog.i18nc("@label", "filename.translate(filename.maketrans(input[], output[], remove[])")
                            }
                        }
                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter
                            x: 25

                            UM.Label {
                                text: catalog.i18nc("@label", "Input")
                            }
                            Rectangle {
                                width: 120
                                implicitHeight: translateInputField.implicitHeight

                                Cura.TextField {
                                    id: translateInputField

                                    width: parent.width
                                    text: manager.settingsTranslateInput
                                    maximumLength: 128
                                    onTextChanged: base.validTranslation = manager.validTranslation(translateInputField.text, translateOutputField.text)
                                    onEditingFinished: { updateConfig() }
                                }
                            }
                        
                            UM.Label {
                                leftPadding: 15
                                text: catalog.i18nc("@label", "Output")
                            }                        
                            Rectangle { 
                                width: 120
                                implicitHeight: translateOutputField.implicitHeight

                                Cura.TextField {
                                    id: translateOutputField
                                
                                    width: parent.width
                                    text: manager.settingsTranslateOutput
                                    maximumLength: 128
                                    onTextChanged: base.validTranslation = manager.validTranslation(translateInputField.text, translateOutputField.text)
                                    onEditingFinished: { updateConfig() }
                                }
                            }
                        
                            UM.Label {
                                leftPadding: 15
                                text: catalog.i18nc("@label", "Remove")
                            }                        
                            Rectangle {
                                width: 120
                                implicitHeight: translateRemoveField.implicitHeight

                                Cura.TextField {
                                    id: translateRemoveField

                                    width: parent.width
                                    text: manager.settingsTranslateRemove
                                    maximumLength: 128
                                    onEditingFinished: { updateConfig() }
                                }
                            }
                        }

                        Item {
                            width: parent.width
                        }
                        UM.Label {
                            visible: !base.validTranslation
                            x: 25
                            font: UM.Theme.getFont("default_italic")
                            color: UM.Theme.getColor("error")
                            text: catalog.i18nc("@error", "Number of mapping characters in the input must be equal to the output!")
                        }
                    }
                }
            }

            Item {
                id: monitorPane

                RowLayout {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: UM.Theme.getSize("default_margin").width
                    }
                    spacing: UM.Theme.getSize("default_margin").width

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop

                        spacing: UM.Theme.getSize("default_margin").height

                        Item {
                            width: parent.width
                            height: 10
                        }
                        RowLayout {
                            width: parent.width
                            x: 15

                            UM.Label {
                                text: catalog.i18nc("@label", "Camera (URL - absolute or path relative to Connection-Url)")
                            }
                        }
                        Cura.TextField {
                            id: cameraUrlField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsCameraUrl                 
                            maximumLength: 1024
                            onEditingFinished: { updateConfig() }
                        }

                    }
                }
 
            }
        }
    }

}
