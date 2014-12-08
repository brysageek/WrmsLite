import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import ArcGIS.Runtime 10.3
import ArcGIS.Runtime.Toolkit.Dialogs 1.0
import QtPositioning 5.3
import QtSensors 5.3


ApplicationWindow {
    id: appWindow
    width: 320
    height: 480
    title: "WrmsLite"

    property int hitFeatureId:0
    property variant attrValue
    property real scaleFactor: 1

    GeodatabaseFeatureServiceTable{
       id:incidentsFeatureService
       url:"https://gisonlinetest.odf.state.or.us/arcgis/rest/services/WRMS/Incidents/MapServer/0"
    }

    Map{
        property Point locationPoint: Point{
            property bool valid: false
            spatialReference: SpatialReference{
                wkid: 4326
            }
        }

        id:mainMap
        anchors.fill: parent

        ArcGISTiledMapServiceLayer{
            id:basemap
            url:"http://services.arcgisonline.com/arcgis/rest/services/USA_Topo_Maps/MapServer"
        }

        ArcGISDynamicMapServiceLayer{
            id:publicOwnership
            url:"https://gisonlinetest.odf.state.or.us/arcgis/rest/services/WebMercator/PublicOwnership/MapServer"
            opacity: 0.4
        }

        ArcGISDynamicMapServiceLayer{
            id:plss
            url: "https://gisonlinetest.odf.state.or.us/arcgis/rest/services/WebMercator/PLSS/MapServer"
        }

        //ArcGISDynamicMapServiceLayer{
           // id:incidents
           // url:"https://gisonlinetest.odf.state.or.us/arcgis/rest/services/WRMS/Incidents/MapServer"
        //}

        FeatureLayer{
            id:incidentsFeatureLayer
            featureTable: incidentsFeatureService
        }

        positionDisplay{
            compass:Compass{
                    id:compass
                }
                positionSource: PositionSource{
                id:positionSource
                onPositionChanged: {
                    mainMap.locationPoint.valid = position.latitudeValid&&position.longitudeValid;
                    mainMap.locationPoint.x = position.coordinate.longitude;
                    mainMap.locationPoint.y = position.coordinate.latitude;
                    locationPointChanged();
                }
            }
                onError: {
                    console.log("There was an error with the Positional Display... Not sure as to why")
                }
        }

        onMapReady:extent=oregonExtent

        onMouseClicked: {
            var features = incidentsFeatureLayer.findFeatures(mouse.x,mouse.y,0,1);
            for (var i=0;i<features.length;i++)
            {
                hitFeatureId =features[i];
                getFields(features);
                identifyDialog.title = "ObjectID" + hitFeatureId;;
                identifyDialog.visible = true;
            }
        }
    }

    SimpleDialog {
            id: identifyDialog
            title: "Object ID: " + hitFeatureId
            height: (column.height * 1.3) * scaleFactor
            width: (column.width * 1.05) * scaleFactor

            Column {
                id: column
                spacing: 5 * scaleFactor
                anchors.centerIn: parent
                Repeater {
                    model: fieldsModel
                    Row {
                        id: row
                        spacing: (80 * scaleFactor)  - nameLabel.width
                        Label {
                            id: nameLabel
                            text: name + ": "
                            font.pixelSize: 10 * scaleFactor
                        }
                        Label {
                            text: value
                            font.pixelSize: 10 * scaleFactor
                        }
                    }
                }
            }

            onRejected: {
                hitFeatureId = 0;
            }
    }

    Envelope{
        id:oregonExtent
        xMin:-13884932.6524728
        xMax:-12942012.5881222
        yMin:5152699.92331632
        yMax:5836354.32813466
        spatialReference: SpatialReference{
            wkid: 102100
        }
    }

    ListModel{
        id:fieldsModel
    }

    Rectangle{
        id:topBar
        color: "black"
        height:parent.height/10
        width:parent.width
        opacity: .75

        Text{
            id:latLonPostionalData
            visible:positionSource.active
            color:"white"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent
        }

        Button{
            id:gpsButton
            iconSource: "qrc:/Resources/GpsIcon.png"
            width: parent.height - parent.height * .1
            height: parent.height - parent.height * .1

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10

            onClicked: {
                positionSource.active = true;

                compass.active = true;
                console.log("Hey you just clicked the button to turn the gps on" + qsTr(mainMap.positionDisplay.mode.toString()))
            }
        }
    }

    function getFields( featureLayer ) {
          fieldsModel.clear();
          var fieldsCount = incidentsFeatureLayer.featureTable.fields.length;
          for ( var f = 0; f < fieldsCount; f++ ) {
              var fieldName = incidentsFeatureLayer.featureTable.fields[f].name;
              attrValue = incidentsFeatureLayer.featureTable.feature(hitFeatureId).attributeValue(fieldName);
              if ( fieldName !== "Shape" ) {
                  var attrString = attrValue;
                  fieldsModel.append({"name": fieldName, "value": attrString});
              }
          }
    }

    function locationPointChanged(){
        latLonPostionalData.text = "Lat: "+positionSource.position.coordinate.latitude+" Lon: "+positionSource.position.coordinate.longitude+" Alt: "+positionSource.position.coordinate.altitude;
    }
}
