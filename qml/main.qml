import QtQuick 2.1
import QtQuick.Controls 1.0
import ArcGIS.Runtime 10.3
import ArcGIS.Runtime.Toolkit.Dialogs 1.0
import QtPositioning 5.3
import QtSensors 5.3


ApplicationWindow {
    id: appWindow
    width: 320
    height: 480
    title: "WrmsLite"

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

        ArcGISDynamicMapServiceLayer{
            id:incidents
            url:"https://gisonlinetest.odf.state.or.us/arcgis/rest/services/WRMS/Incidents/MapServer"
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
        onMapReady:extent=oregonExtent;
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

    Rectangle{
        id:topBar
        color: "black"
        height:parent.height/10
        width:parent.width
        opacity: .75

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
}
