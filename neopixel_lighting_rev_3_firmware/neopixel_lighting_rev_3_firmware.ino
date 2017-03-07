


#include <FastLED.h>


// <-- declare globals

const int num_lights_connected = 3;


const int leds_a_num = 176;
const int leds_a_pin = 12;
const int leds_a_start = 0;

const int leds_b_num = 4;
const int leds_b_pin = 11;
const int leds_b_start = leds_a_num;




const int leds_c_num = 40;
const int leds_c_pin = 10;
const int leds_c_start = leds_b_start + leds_b_num;
/*
const int leds_d_num = 0;
const int leds_d_pin = 9;
const int leds_d_start = leds_c_start + leds_c_num;

const int leds_e_num = 0;
const int leds_e_pin = 8;
const int leds_e_start = leds_d_start + leds_d_num;


*/
const int num_leds_connected = leds_a_num + leds_b_num + leds_c_num + 10;


bool handshake;
String ReadString;
int read_count;
bool settings_data;
bool stringComplete;
int bass[13];
int treble[13];
bool beat;
bool settingsResponse;
// <-- Prerequisites
CRGB leds[num_leds_connected];
int PatternType;
String settingsResponseString;
int FFT[50];
String ReadStrings[13];
int Num_Commands_Recieved;



int LedArray_CurSize = 0;


//Adafruit_NeoPixel strip = Adafruit_NeoPixel(60, 11, NEO_GRB + NEO_KHZ800);
//Adafruit_NeoPixel strip_a[12];
void setup() {

  
  FastLED.addLeds<NEOPIXEL, leds_a_pin>(leds,leds_a_start,leds_a_num);
  FastLED.addLeds<NEOPIXEL, leds_b_pin>(leds,leds_b_start,leds_b_num);
  FastLED.addLeds<NEOPIXEL, leds_c_pin>(leds,leds_c_start,leds_c_num);
  
   Serial.begin(1000000);
   Serial.setTimeout(1); 
   read_count = 0;
   PatternType=0;
   ReadString.reserve(32);
   handshake = false;
   settingsResponse = false;
   settings_data = false;
   for(int i=0;i<num_leds_connected;i++)
   {
    leds[i]=CHSV(0,0,0);
    
   }

 
   
   FastLED.show();
   
   
   
}

void TestPattern2(uint8_t amp,uint8_t treb,int LedStart,int LedAmount) {


int total = amp+treb;
  //int mapamp = map(amp,0,255,0,255);
  //int maptreb = map(treb,0,255,0,255);
  //int brightness = map(amp+treb,0,300,0,255);
  int brightness = (amp+treb)-255;
  int opptreb = 255-treb;
  int oppamp = 255-amp;
  //maptreb = maptreb - 50;
  //mapamp = mapamp - 25;
  if(treb < 0)
  {
    treb = 0;
  }
  if(amp<0)
  {
    amp=0;
  }
  
  
for(int i = LedStart; i<LedStart+LedAmount; i++) {

    leds[i] = CHSV(255-amp,amp,treb);
    if(i == LedStart) {
      //leds[i] = 0;
    }

  
}

}

void TestPattern(uint8_t amp,uint8_t treb,int LedStart,int LedAmount) {


  for(int i = LedStart; i<LedStart+LedAmount; i++) {

    leds[i] = leds[i+1];
    if(i == LedStart) {
      //leds[i] = 0;
    }
    

    
  }
  int total = amp+treb;
  //int mapamp = map(amp,0,255,0,255);
  //int maptreb = map(treb,0,255,0,255);
  //int brightness = map(amp+treb,0,300,0,255);
  int brightness = (amp+treb)-255;
  int opptreb = 255-treb;
  int oppamp = 255-amp;
  //maptreb = maptreb - 50;
  //mapamp = mapamp - 25;
  if(treb < 0)
  {
    treb = 0;
  }
  if(amp<0)
  {
    amp=0;
  }
  
  leds[LedStart+LedAmount] = CHSV(amp,amp,treb);
  
  

  
}

void ChasePattern(uint8_t amp,uint8_t treb,int LedStart,int LedAmount)
{
  //Serial.println("Amp: "+String(amp)+" Treb: "+String(treb)+" Start:"+String(LedStart)+" Amnt:" +String(LedAmount));
  int halfleds = floor(LedAmount/2);
  int halfway = LedStart+halfleds;

 for(int i = LedStart;i<halfway; i++)
 {
  leds[i] = leds[i+1];
 }
 for (int i=LedStart + LedAmount;i>halfway;i--)
 {
  leds[i] = leds[i-1];
 }
  int total = amp+treb;
  //int mapamp = map(amp,0,255,0,255);
  //int maptreb = map(treb,0,255,0,255);
  //int brightness = map(amp+treb,0,300,0,255);
  int brightness = (amp+treb)-255;
  int opptreb = 255-treb;
  int oppamp = 255-amp;
  //maptreb = maptreb - 50;
  //mapamp = mapamp - 25;
  if(treb < 10)
  {
    treb = 0;
  }
  if(amp<10)
  {
    amp=0;
  }
  
  leds[halfway] = CHSV(amp,amp,treb);
  leds[halfway+2] = CHSV(oppamp,amp,treb);
  
 
  

  

  
}
/*
void Rainbow(uint8_t amp,uint8_t treb ,int LedStart, int LedNum)
{

  for(int i=0;i<NUM_LEDS;i++)
  {
    leds[i] = CRGB::Black;
  }

  int divpx = floor(NUM_LEDS/4);
  int total = amp+treb;
  int mapamp = map(amp,0,150,0,255);
  int maptreb = map(treb,0,150,0,255);
  int brightness = map(amp+treb,0,300,0,255);
  int pxmapBass = map(amp,0,150,0,divpx);
  int pxmapTreb = map(treb,0,150,0,divpx);
  int opptreb = 150-treb;
  int oppamp = 150-amp;
  //maptreb = maptreb - 50;
  if(maptreb < 0)
  {
    maptreb = 0;
  }

  for(int i=0;i<pxmapBass;i++)
  {
    int mul = 10;
    int opp = pxmapBass-i;
    leds[i] = CHSV(opp*mul,255,mapamp);
    leds[NUM_LEDS-i] = CHSV(opp*mul,255,mapamp);
  }
  for (int i=0;i<pxmapTreb;i++)
  {
    int mul = 10;
    int opp = pxmapTreb-i;
    leds[NUM_LEDS/2-i] = CHSV(opp*mul,255,maptreb);
    leds[NUM_LEDS/2+i] = CHSV(opp*mul,255,maptreb);
  }
  
  
  

  FastLED.show();
}

*/

void loop() {
     
    if(handshake == false)
    {
      Serial.print('N');
      delay(300);
    }
   
   

}


void serialEvent()
{
  
  while(Serial.available()) {
  
    char inChar = (char)Serial.read();
    
    
    //Serial.print(inChar);
    if(inChar == 'A') {handshake = true; ReadString = ""; read_count = 0;return;}
   

      
    if(handshake == true && inChar == 'B') {Num_Commands_Recieved+=1;}
    if(handshake == true && inChar !='A')
    {
      ReadString += inChar;
    
    if(inChar == '#') {
      
      serial_breakdown();
      //Serial.println(ReadString);
      ReadString = ""; 
      Num_Commands_Recieved = 0;
      
    }
    
   
    }
    
  }
  
  
}


int CheckOccurence(String str,char c) {

  

  
}


void serial_breakdown()
{
  int command_pointer = 0;
  for(int i=0;i<Num_Commands_Recieved;i++) {

    bass[i] = 0;
    treble[i] = 0;

    // each command has 8 characters, B000T000, with a # finishing the command string and sending it to this code.
    // At the moment, serial_breakdown will recieve B000T000B000T000# and must split this.

    if(ReadString.substring(command_pointer,command_pointer+1)=="B")
    {
     
     bass[i] = ReadString.substring(command_pointer+1,command_pointer+4).toInt();
     
     
    }
    if(ReadString.substring(command_pointer+4,command_pointer+5)=="T")
    {
      
     treble[i] = ReadString.substring(command_pointer+5,command_pointer+8).toInt();
     
     
    
    }



    
    //Serial.println("Pointer: "+String(command_pointer)+" B: "+ String(bass[i]) + " T: " + String(treble[i])+" END");
    command_pointer+=8;
    //PUT PATTERN DATA HERE FOR EACH LIGHT
   
    
    }
   ChasePattern(bass[0],treble[0],leds_a_start,leds_a_num);
   ChasePattern(bass[1],treble[1],leds_b_start,leds_b_num);
   ChasePattern(bass[2],treble[2],leds_c_start,leds_c_num);
   FastLED.show();
    
}


