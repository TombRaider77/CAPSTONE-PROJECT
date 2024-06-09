#include <WiFi.h>
#include <WiFiAP.h>
#include <WiFiClient.h>
#include <WiFiGeneric.h>
#include <WiFiMulti.h>
#include <WiFiSTA.h>
#include <WiFiScan.h>
#include <WiFiServer.h>
#include <WiFiType.h>
#include <WiFiUdp.h>



// This code does not average multiple position measurements!
#include <HTTPClient.h>

#include <SPI.h>
#include "DW1000Ranging.h"
#include "DW1000.h"

//#define DEBUG_TRILAT   //prints in trilateration code
//#define DEBUG_DIST     //print anchor distances

#define SPI_SCK 18
#define SPI_MISO 19
#define SPI_MOSI 23
#define DW_CS 2

// connection pins
const uint8_t PIN_RST = 34; // reset pin
const uint8_t PIN_IRQ = 35; // irq pin
const uint8_t PIN_SS = 2;   // spi select pin

// TAG antenna delay defaults to 16384
// leftmost two bytes below will become the "short address"
char tag_addr[] = "7D:00:22:EA:82:60:3B:9C";

// variables for position determination
#define N_ANCHORS 3
#define ANCHOR_DISTANCE_EXPIRED 5000   //measurements older than this are ignore (milliseconds)

// global variables, input and output

const char* ssid = "MonaConnect";
const char* password = "";
const char* serverName = "http://172.16.188.183/UWBDATABASE/insert_distance1.inc.php";

float anchor_matrix[N_ANCHORS][3] = { 
  {0.00, 22.41, 0.00},  
  {14.42, 22.41, 0.00}, 
  {0.07, 0.00, 0.00},   
}; 

uint32_t last_anchor_update[N_ANCHORS] = {0}; //millis() value last time anchor was seen
//can only represent non negative values
float last_anchor_distance[N_ANCHORS] = {0.0}; //most recent distance reports

float current_tag_position[2] = {0.0, 0.0}; //global current position (meters with respect to anchor origin)
//float current_distance_rmse = 0.0;  //rms error in distance calc => crude measure of position error (meters).  Needs to be better characterized

void setup()
{
  Serial.begin(115200);
  delay(1000);
    WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWiFi connected.");
  Serial.println("IP address: " + WiFi.localIP().toString());

  //initialize configuration
  SPI.begin(SPI_SCK, SPI_MISO, SPI_MOSI);
  DW1000Ranging.initCommunication(PIN_RST, PIN_SS, PIN_IRQ); //Reset, CS, IRQ pin

  DW1000Ranging.attachNewRange(newRange);
  DW1000Ranging.attachNewDevice(newDevice);
  DW1000Ranging.attachInactiveDevice(inactiveDevice);

  // start as tag, do not assign random short address

  DW1000Ranging.startAsTag(tag_addr, DW1000.MODE_LONGDATA_RANGE_LOWPOWER, false);
}

void loop()
{

    /*static bool first1 = true;
    int i, detected;
    static float dis1, dis2, dis3, coorx, coory;*/
    

 
  DW1000Ranging.loop();
  //static bool dt=true;
  //put fabs for distnce here
  //if detected==3 put post request here
  //if first1
/*if (dt == true) {
    if (first1) {
      if ( current_tag_position[0] <= 14.49 && current_tag_position[1] <= 22.50 ) {
    //Serial.println("HIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII");

            // Create HTTP client to send the data
            HTTPClient http;
            http.begin(serverName);
            http.addHeader("Content-Type", "application/x-www-form-urlencoded");

            String httpRequestData = "distance1=" + String(last_anchor_distance[0]) +
                                    "&distance2=" + String(last_anchor_distance[1]) +
                                    "&distance3=" + String(last_anchor_distance[2]) +
                                    "&coordinateX=" + String(current_tag_position[0]) +
                                    "&coordinateY=" + String(current_tag_position[1]);
                                     

             //Serial.println("444444444444444444444444444444444444");
            int httpResponseCode = http.POST(httpRequestData);
           //Serial.println("BBBBBBBYYYYYYYYYYYYEEEEEEEEE");

            if (httpResponseCode > 0) {
                String response = http.getString();
                Serial.println("HTTP Response code: " + String(httpResponseCode));
                Serial.println("Response: " + response);
            } else {
                Serial.println("Error on sending POST: " + String(httpResponseCode));
            }

            http.end();
        } else {
            Serial.println("OUT OF RANGE or INVALID DATA!");
        }





      // put the post request here
      // save the values as dis1, dis2, dis3, coorx, coory
       //static float dis1, dis2, dis3, coorx, coory;
      first1 = false;
      dis1= last_anchor_distance[0];
      dis2= last_anchor_distance[1];
      dis3=last_anchor_distance[2];
      coorx=current_tag_position[0];
      coory= current_tag_position[1];     
      dt= false;

    } else {
      if ( current_tag_position[0] <= 14.49 && current_tag_position[1] <= 22.50 ) {
        /*dis1= last_anchor_distance[0];
      dis2= last_anchor_distance[1];
      dis3=last_anchor_distance[2];
      coorx=current_tag_position[0];
      coory= current_tag_position[1];     
      // check if the values are within 2 units of the previous values
      if (abs(last_anchor_distance[0] - dis1) <= 2 &&
          abs(last_anchor_distance[1] - dis2) <= 2 &&
          abs(last_anchor_distance[2] - dis3) <= 2 &&
          abs(current_tag_position[0] - coorx) <= 2 &&
          abs(current_tag_position[1] - coory) <= 2) {

      dis1= last_anchor_distance[0];
      dis2= last_anchor_distance[1];
      dis3=last_anchor_distance[2];
      coorx=current_tag_position[0];
      coory= current_tag_position[1];  

      
    //Serial.println("HIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII");

            // Create HTTP client to send the data
            HTTPClient http;
            http.begin(serverName);
            http.addHeader("Content-Type", "application/x-www-form-urlencoded");

            String httpRequestData = "distance1=" + String(last_anchor_distance[0]) +
                                    "&distance2=" + String(last_anchor_distance[1]) +
                                    "&distance3=" + String(last_anchor_distance[2]) +
                                    "&coordinateX=" + String(current_tag_position[0]) +
                                    "&coordinateY=" + String(current_tag_position[1]);
                                     

             //Serial.println("444444444444444444444444444444444444");
            int httpResponseCode = http.POST(httpRequestData);
           //Serial.println("BBBBBBBYYYYYYYYYYYYEEEEEEEEE");

            if (httpResponseCode > 0) {
                String response = http.getString();
                Serial.println("HTTP Response code: " + String(httpResponseCode));
                Serial.println("Response: " + response);
            } else {
                Serial.println("Error on sending POST: " + String(httpResponseCode));
            }

            http.end();
            dt=false;
        } else {
            Serial.println("OUT OF RANGE or INVALID DATA!");
            dt=false;
        }



        // save the new values as dis1, dis2, dis3, coorx, coory
        // if there are 6 or more instances of the values being more than 2 units away, post the result
       
      } else {
        dt=false;
        // reset first and post_count
        //first = true;
       // post_count = 0;
      }
    }


  }


dt=false;*/

}

// collect distance data from anchors, presently configured for 4 anchors
// solve for position if at least 3 are present

void newRange()
{
  int i; //indices, expecting values 1 to 4
  //index of this anchor, expecting values 1,2,3
  int index = DW1000Ranging.getDistantDevice()->getShortAddress() & 0x03; 
  
  if (index > 0) {
    last_anchor_update[index - 1] = millis();  //decrement for array index
    float range = DW1000Ranging.getDistantDevice()->getRange();
    last_anchor_distance[index-1] = range;
 
  }
  
  //loop iterates once for each detected anchor
  //saves that distance an time then if it expires take it again
  //for loop belows loops 3 times, check current time
  //against last recorded measure of specific anchhor
  //if large enough the anchor distance is retaken
  //if not it is saved and the detected  conuter is incremented
  //but is then reset again later
  //loop accepts new device new new id
  //takes the distance and stores it 
  //take the time it took to update
  //now when we run the for loop, detected will be equal to 2,
  ///as 2 anchors are present, detected now is 2 but its not enough
  //if the first anchor distance is now expired when the time is compared in the for loop
  //it is redone, the other anchor is then searched for
  //the distance and address and time is noted, now we have 3 distances
  //and triangulatin can begin 

  //after the code runs once, now that the anchors are actively recognized and running
  //they continously send the tag data
  //the second time and unwards this is looped it collects the data for each single 
  //anchor piont, this time without th delay taken to actually identify the anchor
  //gets it most recent range and time, then when all three are collected start trialgulation 
  ///again
  int detected = 0;

  //reject old measurements
  for (i = 0; i < N_ANCHORS; i++) {
    //iterates through all anchors and collect the 
    //valid time, increments detected
    if (millis() - last_anchor_update[i] > ANCHOR_DISTANCE_EXPIRED) last_anchor_update[i] = 0; //not from this one
    if (last_anchor_update[i] > 0) detected++;

  }

  if ( detected == 3) { //three measurements TODO: check millis() wrap



    trilat2D_3A();

    //output the values (X, Y and error estimate)
    Serial.print("P= ");
    Serial.print(current_tag_position[0]);
    Serial.write(',');
    Serial.print(current_tag_position[1]);
    Serial.write(',');
    

  if ( current_tag_position[0] <= 14.49 && current_tag_position[1] <= 22.421 && last_anchor_distance[0] <= 27.5 && last_anchor_distance[1] <= 27.5 && last_anchor_distance[2] <= 27.5 && current_tag_position[0] >= 0 &&
   current_tag_position[1] >=0 ) {
    //Serial.println("HIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII");

            // Create HTTP client to send the data
            HTTPClient http;
            http.begin(serverName);
            http.addHeader("Content-Type", "application/x-www-form-urlencoded");

            String httpRequestData = "distance1=" + String(last_anchor_distance[0]) +
                                    "&distance2=" + String(last_anchor_distance[1]) +
                                    "&distance3=" + String(last_anchor_distance[2]) +
                                    "&coordinateX=" + String(current_tag_position[0]) +
                                    "&coordinateY=" + String(current_tag_position[1]);
                                     

             //Serial.println("444444444444444444444444444444444444");
            int httpResponseCode = http.POST(httpRequestData);
           //Serial.println("BBBBBBBYYYYYYYYYYYYEEEEEEEEE");

            if (httpResponseCode > 0) {
                String response = http.getString();
                Serial.println("HTTP Response code: " + String(httpResponseCode));
                Serial.println("Response: " + response);
            } else {
                Serial.println("Error on sending POST: " + String(httpResponseCode));
            }

            http.end();
        } else {
            Serial.println("OUT OF RANGE or INVALID DATA!");
        }


  

  }
}  

void newDevice(DW1000Device *device)
{+
  Serial.print("Device added: ");
  Serial.println(device->getShortAddress(), HEX);
}

void inactiveDevice(DW1000Device *device)
{
  Serial.print("delete inactive device: ");
  Serial.println(device->getShortAddress(), HEX);
}

int trilat2D_3A(void) {

 // keeps track of whether its the first time the function is being called
  static bool first = true;  //first time through, some preliminary work

  //stores temporary values,b for immediate caluclatoin, d for distances from anchors

 
   //stores temporary values,b for immediate caluclatoin, d for distances from anchors
  float b[N_ANCHORS], d[N_ANCHORS]; //temp vector, distances from anchors






 //least squares formula
  //2*A*X=B
  //X= 0.5 * Ainv * b
  // A (Ainv) is an inverted 2x2 matrix representing the anchor arrangement
  //x (current_tag_position[0,1])is a 2x1 vector representing unknown tag coordinates x and y
  //B is a 2x1 vector intermediate values calculated based 
  //on the measured distances (d) and anchor locations (k)

//Ainv stores the inverted anchor matrix(for solving the linear system)
//k stores the pre calculated values based on anchor coordinates(to simplify calc)
/*(x − xi)^2 + (y − yi)^2 + (z − zi)^2 = d^2i */
/*2x (x2 − x1) − 2y (y2 − y1) + 2z (z2 − z1)
= d^2(1) − d^2(2) − x^(2)1 − y(2)1 − z(2)1 + x(2)2 + y(2)2 + z(2)2
*/

//system of linear equation this equates to r=A^-1*b
//where r is the values for x,y and z


  static float Ainv[2][2], k[N_ANCHORS]; //these are calculated only once

  int i;
  // copy distances to local storage
  for (i = 0; i < N_ANCHORS; i++) d[i] = last_anchor_distance[i];


  if (first) {  //intermediate fixed vectors
    first = false;
 // These arrays are used for temporary calculations within this block.
    float x[N_ANCHORS], y[N_ANCHORS]; //intermediate vectors
    float A[2][2];  //the A matrix for system of equations to solve
  //iterates through each anchor and extracts the x and y coordinates
    for (i = 0; i < N_ANCHORS; i++) {
      x[i] = anchor_matrix[i][0];
      y[i] = anchor_matrix[i][1];
       //formula for constant value ,based on the anchor squared coordinates 
      k[i] = x[i] * x[i] + y[i] * y[i];
    }


        // set up least squares equation
    //sets up the matrix declared as a to be used in the least  squares eqn
    // matrix on relative position of anchors

    for (i = 1; i < N_ANCHORS; i++) {
      A[i - 1][0] = x[i] - x[0];
      A[i - 1][1] = y[i] - y[0];

    }
    //invert A
    //to solve in the system of equations
    float det = A[0][0] * A[1][1] - A[1][0] * A[0][1];
   /* if (fabs(det) < 1.0E-4) {
      Serial.println("***Singular matrix, check anchor coordinates***");
      while (1) delay(1); //hang
    }*/



    det = 1.0 / det;
    //scale adjoint
    Ainv[0][0] =  det * A[1][1];
    Ainv[0][1] = -det * A[0][1];
    Ainv[1][0] = -det * A[1][0];
    Ainv[1][1] =  det * A[0][0];
  } //end if (first);


  //iterates through the distances d and 
    //calculates the b vector elements used in the least squares solution
  for (i = 1; i < N_ANCHORS; i++) {
    b[i - 1] = d[0] * d[0] - d[i] * d[i] + k[i] - k[0];
  }

  //least squares solution for position
  //solve:  2 A rc = b
    //lines use the inverted matrix Ainv and the b vector 
  //to solve for the tag's coordinates in X (0) and Y (1) dimensions.
  //X = 0.5 * Ainv * b
  //Y = 0.5 * Ainv * b

  current_tag_position[0] = 0.5 * (Ainv[0][0] * b[0] + Ainv[0][1] * b[1]);
  current_tag_position[1] = 0.5 * (Ainv[1][0] * b[0] + Ainv[1][1] * b[1]);
  //

  // calculate rms error for distances
  

  return 1;
}  //end trilat2D_3A




















