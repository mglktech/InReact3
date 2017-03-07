// Need G4P library
import g4p_controls.*;
import processing.serial.*;
import processing.sound.*;
import ddf.minim.*;
import ddf.minim.analysis.*;


Minim minim;
Amplitude rms;
AudioInput in;
AudioIn device;
ddf.minim.analysis.FFT fft;
Serial port;


// Custom Bools
boolean settings_open;
boolean ready;
boolean handshake;
boolean connected;
// Existing EZHook values
String DebugText;
int appfps = 60;
int threadfps = 60;
int fftLines = 50;
color DebugTextColor;


float[] RawFFT;

// New EZhook values
Table LightSettings;
int pointer;
int[] id;
int[] Pin;
String[] LightName;
int[] LedsAmount;
int[] Pattern;
int[] Mode;
int[] BassSliderValue;
int[] TrebSliderValue;
int[] TrebArraySize;
int[] LowPass;
float[] MulBright;
float[] MulColor;
float[] bass;
float[] treble;
String[] LightNameVisualBuffer;
String[] ports;
String[] command;
String SettingsFileName = "userdata";



void TableFirstLoad() {
  LightName = new String[1];
  command[0] = "loadTable";
  TableHandler(command);
  command[0] = "loadArraysFromTable";
  TableHandler(command);
  if(LightName[0] == null) {
    println("Error initializing table. Better make a new one!");
    command[0] = "new";
    TableHandler(command);
    println("Verifying new table has initialized correctly...");
    command[0] = "loadArraysFromTable";
    TableHandler(command);
    print(LightName[0]);
    if(LightName[0] == null) {
      println("Damn. Table is still missing! program cannot run. Maybe the CSV is currently in use?");
      
    }
    
    
    
  }
  
  println("TableFirstLoad:END");
  
  
}


 

void TableHandler(String[] data) {
  
  if(data[0] == "loadTable") {
    
    try {
    
     println("Loading Table...");
     LightSettings = loadTable("data/userdata.csv","header");
     // Table loaded fine, now to dump the table into useable values.
     command = new String[] {"loadArraysFromTable"};
     TableHandler(command);
       
     }
  
  catch(Exception e) {}
  }
     
  if(data[0] == "loadArraysFromTable") {
    
    try {
    
    println("LoadArraysFromTable Called.");
    int TableRowCount = LightSettings.getRowCount();
    
    id = new int[TableRowCount];
    Pin = new int[TableRowCount];
    LightName = new String[TableRowCount];
    LedsAmount = new int[TableRowCount];
    Pattern = new int[TableRowCount];
    Mode = new int[TableRowCount];
    BassSliderValue = new int[TableRowCount];
    TrebSliderValue = new int[TableRowCount];
    TrebArraySize = new int[TableRowCount];
    MulBright = new float[TableRowCount];
    MulColor = new float[TableRowCount];
    LowPass = new int[TableRowCount];

    for(int i=0;i<TableRowCount;i++) {
       TableRow row = LightSettings.getRow(i);
       id[i] = row.getInt("id");
       Pin[i] = row.getInt("Pin");
       LightName[i] = row.getString("LightName");
       LedsAmount[i] = row.getInt("LedsAmount");
       Pattern[i] = row.getInt("Pattern");
       Mode[i] = row.getInt("Mode");
       BassSliderValue[i] = row.getInt("BassSliderValue");
       TrebSliderValue[i] = row.getInt("TrebSliderValue");
       TrebArraySize[i] = row.getInt("TrebArraySize");
       MulBright[i] = row.getFloat("MulBright");
       MulColor[i] = row.getFloat("MulColor");
       LowPass[i] = row.getInt("LowPass");
       println(LightName[i]);
     }
     ready = true;
     
    }
    
    catch(Exception e){}
     
     
    
  }
  
  if(data[0] == "saveTable") {
    
    println("saveTable called");
    saveTable(LightSettings,"data/userdata.csv");
    
  }
  
  
  if(data[0] == "saveArraysToTable") {
    
    println("saveArraysToTable called");
    for(int i=0;i<LightSettings.getRowCount();i++) {
      TableRow row = LightSettings.getRow(i);
      
    
      row.setInt("id",id[i]);
      row.setInt("Pin",Pin[i]);
      row.setString("LightName",LightName[i]);
      row.setInt("LedsAmount",LedsAmount[i]);
      row.setInt("Pattern",Pattern[i]);
      row.setInt("Mode",Mode[i]);
      row.setInt("BassSliderValue",BassSliderValue[i]);
      row.setInt("TrebSliderValue",TrebSliderValue[i]);
      row.setInt("TrebArraySize",TrebArraySize[i]);
      row.setFloat("MulBright",MulBright[i]);
      row.setFloat("MulColor",MulColor[i]);
      row.setInt("LowPass",LowPass[i]);
    
    
  }
  
  
    
  }
    
    
  
  if(data[0] == "new") {
    
    println("Creating new table...");
    LightSettings = new Table();
    LightSettings.addColumn("id",Table.INT);
    LightSettings.addColumn("Pin",Table.INT);
    LightSettings.addColumn("LightName",Table.STRING);
    LightSettings.addColumn("LedsAmount",Table.INT);
    LightSettings.addColumn("Pattern",Table.INT);
    LightSettings.addColumn("Mode",Table.INT);
    LightSettings.addColumn("BassSliderValue",Table.INT);
    LightSettings.addColumn("TrebSliderValue",Table.INT);
    LightSettings.addColumn("TrebArraySize",Table.INT);
    LightSettings.addColumn("MulBright",Table.FLOAT);
    LightSettings.addColumn("MulColor",Table.FLOAT);
    LightSettings.addColumn("LowPass",Table.INT);
    // Okay, that's the table made, but it still doesn't have any values. Let's add some default values!
    TableRow row = LightSettings.addRow();
    row.setInt("id",0);
    row.setInt("Pin",12);
    row.setString("LightName","My First Light");
    row.setInt("LedsAmount",170);
    row.setInt("Pattern",1);
    row.setInt("Mode",1);
    row.setInt("BassSliderValue",3);
    row.setInt("TrebSliderValue",4); 
    row.setInt("TrebArraySize",15);
    row.setFloat("MulBright",1);
    row.setFloat("MulColor",1);
    row.setInt("LowPass",0);
    // That's the default values loaded into the table, now lets save the table into that pesky file...
    println("New: Saving table...");
    saveTable(LightSettings,"data/userdata.csv");
      
    
  }
  
  
  if(data[0] == "newline") {
    
    TableRow row = LightSettings.addRow();
    row.setInt("Pin",0);
    row.setString("LightName","new");
    row.setInt("LedsAmount",0);
    row.setInt("Pattern",1);
    row.setInt("Mode",1);
    row.setInt("BassSliderValue",0);
    row.setInt("TrebSliderValue",0);
    row.setInt("TrebArraySize",0);
    row.setFloat("MulBright",1.0);
    row.setFloat("MulColor",1.0);
    row.setInt("LowPass",0);
    command = new String[] {"loadArraysFromTable"};
    TableHandler(command);
    
  }
    
    
  delay(5);
  
    
    
  }
  
  
  
 
    
    
    
    
 
    
void UpdateGDropBoxes() {
  
  lstSelectLight.setItems(LightName, 0);
  lstSelectLight.setSelected(pointer);
  if(settings_open) {
    
    lstLoadLightSettings.setItems(LightName, 0);
    lstLoadLightSettings.setSelected(pointer);
  }
  
  
}

void UpdateSelectionsFromPointer() {
  
  println("UpdateSelectionsFromPointer() called");
  int i = pointer;
  
  sliMul.setValueX(MulColor[i]);
  sliMul.setValueY(MulBright[i]);
  sliBass.setValue(BassSliderValue[i]);
  sliTreble.setValue(TrebSliderValue[i]);
  sliLowPass.setValue(LowPass[i]);
  txbTrebArraySize.setText(str(TrebArraySize[i]));
  if(Mode[i] == 1) {
  chkMode.setSelected(true);
  }
  if(Mode[i] == 0) {
    chkMode.setSelected(false);
  }
  if(settings_open) {
    txbPin.setText(str(Pin[i]));
    txbLightName.setText(LightName[i]);
    txbLEDsAmount.setText(str(LedsAmount[i]));
    
    
    
    
  }
  
    
  
  
  
}

void SaveSelectionsToArray() {
  
  int i = pointer;
  
 
  MulColor[i] = sliMul.getValueXF();
  MulBright[i] = sliMul.getValueYF();
  BassSliderValue[i] = sliBass.getValueI();
  TrebSliderValue[i] = sliTreble.getValueI();
  TrebArraySize[i] = int(txbTrebArraySize.getText());
  LowPass[i] = sliLowPass.getValueI();
  if(chkMode.isSelected()) {
  Mode[i] = 1;
  }
  if(chkMode.isSelected() == false) {
    Mode[i] = 0;
  }
  
  if(settings_open) {
    Pin[i] = int(txbPin.getText());
    LedsAmount[i] = int(txbLEDsAmount.getText());
    LightName[i] = txbLightName.getText();
    
    
    
    
  }
  
  
  
  
}



  
  
  
  
  







public void setup(){
  size(800, 300, JAVA2D);
  command = new String[] {"",""};
  LightNameVisualBuffer = new String[] {"Loading..."};
  bass = new float[60];
  treble = new float[60];
  pointer = 0;
  TableFirstLoad();
  Construct();
  createGUI();
  UpdateGDropBoxes();
  UpdateSelectionsFromPointer();
  thread("portWrite");
  
   

  
  
  // Place your setup code here
  
}

public void draw(){
  background(100);
  customGUI();
  DrawFFTSpectrum();
  GetFFTData();
}

void Construct()
{
  
  
 
  
  minim = new Minim(this);
  in = minim.getLineIn();
  device = new AudioIn(this, 0);
  device.start();
  rms = new Amplitude(this);
  rms.input(device);
  ports = Serial.list();
  
  
  fft = new ddf.minim.analysis.FFT(in.bufferSize(), in.sampleRate());
  /*
  port = new Serial(this, Serial.list()[COMval],1000000); 
  port.clear();
  port.stop();
  */
    
  
  
  //fft.forward(in.mix);
  
  //RawFFT = new float[specSize];
  
  
  
}

// Use this method to add additional statements
// to customise the GUI controls
public void customGUI(){
  
  if(settings_open == true) {
    btnSettings.setEnabled(false);
  }
  if(settings_open == false) {
    btnSettings.setEnabled(true);
  }
  
  
  
  lblDebug.setText(DebugText);
    background(100,100,100);
  fill(50,50,50);
  rect(15,10,500,170); // Graph Background
  rect(5,275,505,20); // Debug Background
  fill(200);
  rect(15,10,5,160);
  fill(0,150,0);
  rect(20+(sliTreble.getValueI()*10),170,TrebArraySize[pointer]*10,10);
  fill(0,0,150);
  rect(20,170,sliBass.getValueI()*10,10);
  //fill(0,0,150);
  //rect(20,170,realcutstart,10);
  //fill(150,0,0);
  //rect(20+realcutaddx,170,490-realcutaddx,10);
  for(int i=0;i<=15;i++)
  {
    stroke(100);
    
    if(i==5)
    {
      stroke(200);
      fill(200);
      text("100",535,25+i*10);
    }
    if(i==10)
    {
      stroke(200);
      fill(200);
      text("50",535,25+i*10);
    }
    if(i==0)
    {
      stroke(200);
      fill(200);
      text("150",535,25+i*10);
      
    }
    if(i==15)
    {
      stroke(200);
      fill(200);
      text("0",535,25+i*10);
      
    }
    
    line(20,20+i*10,510,20+i*10);
    
    
    
  }
  for(int i=1; i<=50;i++)
  {
   stroke(100);
    line(10+i*10,20,10+i*10,180);
    
    
    
    
  }
  stroke(0);
  
  
  

}

public void HandleButtonEvents(GButton source, GEvent event) {
  
  if(source == btnSettings && event == GEvent.CLICKED) {
    CreateSettingsWindow();
    settings_open = true;
    UpdateGDropBoxes();
    UpdateSelectionsFromPointer();
    
  }
  if(source == btnSave && event == GEvent.CLICKED) {
    
    
    SaveSelectionsToArray();
    command[0] = "saveArraysToTable";
    TableHandler(command);
    command[0] = "saveTable";
    TableHandler(command);
    UpdateSelectionsFromPointer();
    UpdateGDropBoxes();
    
    
  }
  if(source == btnNewLight && event == GEvent.CLICKED) {
    command[0] = "newline";
    TableHandler(command);
    UpdateGDropBoxes();
    UpdateSelectionsFromPointer();
    
  }
  if(source == btnExecute && event == GEvent.CLICKED) {
    if(connected == false) {
      int sel = lstCom.getSelectedIndex();
      String curport = Serial.list()[sel].toString();
      port = new Serial(this, Serial.list()[sel],1000000);
      DebugText = "Connecting to: "+curport+" ...";
      
      
    }
    
    
    
  }
  
  
  
}
  
  
public void HandleSliderEvents(GSlider source, GEvent event) {
  
  if(source == sliBass && event == GEvent.VALUE_STEADY) {
    lblsliBass.setText(sliBass.getValueS());
    SaveSelectionsToArray();
    
  }
  if(source == sliTreble && event == GEvent.VALUE_STEADY) {
    lblsliTreble.setText(sliTreble.getValueS());
    SaveSelectionsToArray();
    
  }
  if(source == sliLowPass && event == GEvent.VALUE_STEADY) {
    
    SaveSelectionsToArray();
  }
  
  
  
}

public void Handle2DSliderEvents(GSlider2D source, GEvent event) {
  
  if(source == sliMul && event == GEvent.VALUE_STEADY) {
    
    float x = sliMul.getValueXF();
    float y = sliMul.getValueYF();
    String strX = sliMul.getValueXS();
    String strY = sliMul.getValueYS();
    lblsliMul.setText(strX+" , "+strY);
    SaveSelectionsToArray();
    
  }
  
  
  
   //lblsliMul
  
}

public void HandleDropListEvents(GDropList source, GEvent event) {
  
  if(source == lstCom && event == GEvent.SELECTED) {
    
    DebugText = "Ready to Connect: "+lstCom.getSelectedText()+"...";
    
  }
  if(source == lstSelectLight && event == GEvent.SELECTED) {
    
    if(settings_open) {
      
      pointer = lstLoadLightSettings.getSelectedIndex();
      
    }
    
    else {pointer = lstSelectLight.getSelectedIndex();}
    UpdateSelectionsFromPointer();
    
    
    
  }
  if(source == lstLoadLightSettings && event == GEvent.SELECTED) {
    
    pointer = lstLoadLightSettings.getSelectedIndex();
    UpdateSelectionsFromPointer();
    
  }
  
  
  
  
 
  
}

public void HandleTextboxEvents(GTextField source, GEvent event) {
  
  if(source == txbTrebArraySize && event == GEvent.ENTERED) {
    
    try {
      TrebArraySize[pointer] = int(txbTrebArraySize.getText());
      println("worked. "+TrebArraySize);
      SaveSelectionsToArray();
    }
    catch(IllegalArgumentException e)  {
   
    println("Please put Numbers not Letters!");
  }
    
  }
  
  
  
}
public void chkMode_clicked(GCheckbox checkbox, GEvent event) {
  
  SaveSelectionsToArray();

}
public void winLightSettings_OnClose(GWindow window) {
  settings_open = false;
  
}

synchronized public void winLightSettings_draw(PApplet appc, GWinData data) { 
  appc.background(100);
} 

public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.GOLD_SCHEME);
  G4P.setCursor(ARROW);
  surface.setTitle("InReact Version 0.3");
  btnExecute = new GButton(this, 715, 265, 80, 30);
  btnExecute.setText("Connect");
  btnExecute.addEventHandler(this, "HandleButtonEvents");
  btnSettings = new GButton(this, 630, 265, 80, 30);
  btnSettings.setText("Settings");
  btnSettings.addEventHandler(this, "HandleButtonEvents");
  sliMul = new GSlider2D(this, 633, 160, 100, 100);
  sliMul.setLimitsX(0, 0, 10);
  sliMul.setLimitsY(0, 10, 0);
  sliMul.setNumberFormat(G4P.DECIMAL, 1);
  //sliMul.setPrecision(2);
  sliMul.setOpaque(true);
  sliMul.addEventHandler(this, "Handle2DSliderEvents");
  lstSelectLight = new GDropList(this, 690, 20, 90, 80, 3);
  lstSelectLight.setItems(LightNameVisualBuffer, 0);
  lstSelectLight.addEventHandler(this, "HandleDropListEvents");
  lstCom = new GDropList(this, 590, 20, 90, 80, 3);
  lstCom.setItems(ports, 0);
  lstCom.addEventHandler(this, "HandleDropListEvents");
  sliBass = new GSlider(this, 10, 190, 500, 40, 10.0);
  sliBass.setLimits(0, 0, 50);
  sliBass.setNumberFormat(G4P.INTEGER, 0);
  sliBass.setOpaque(false);
  sliBass.addEventHandler(this, "HandleSliderEvents");
  sliTreble = new GSlider(this, 10, 220, 500, 40, 10.0);
  sliTreble.setLimits(0, 0, 50);
  sliTreble.setNumberFormat(G4P.INTEGER, 0);
  sliTreble.setOpaque(false);
  sliTreble.addEventHandler(this, "HandleSliderEvents");
  sliLowPass = new GSlider(this, 575, 20, 150, 100, 10.0);
  sliLowPass.setRotation(PI/2, GControlMode.CORNER);
  sliLowPass.setLimits(0, 150, 0);
  sliLowPass.setNumberFormat(G4P.INTEGER, 0);
  sliLowPass.setOpaque(false);
  sliLowPass.addEventHandler(this, "HandleSliderEvents");
  chkMode = new GCheckbox(this, 631, 134, 120, 20);
  chkMode.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  chkMode.setText("MODE");
  chkMode.setOpaque(false);
  chkMode.addEventHandler(this, "chkMode_clicked");
  lblDebug = new GLabel(this, 10, 275, 500, 20);
  lblDebug.setText("Debug");
  lblDebug.setOpaque(false);
  lblsliMul = new GLabel(this, 740, 240, 50, 20);
  lblsliMul.setText("0,0");
  lblsliMul.setOpaque(false);
  lblsliBass = new GLabel(this, 515, 200, 50, 20);
  lblsliBass.setText("0");
  lblsliBass.setTextBold();
  lblsliBass.setOpaque(false);
  lblsliTreble = new GLabel(this, 570, 230, 50, 20);
  lblsliTreble.setText("0");
  lblsliTreble.setTextBold();
  lblsliTreble.setOpaque(false);
  txbTrebArraySize = new GTextField(this, 515, 230, 50, 20, G4P.SCROLLBARS_NONE);
  txbTrebArraySize.setOpaque(false);
  txbTrebArraySize.addEventHandler(this, "HandleTextboxEvents");
  
}

public void CreateSettingsWindow() {
  winLightSettings = GWindow.getWindow(this, "Light Settings", 0, 0, 300, 150, JAVA2D);
  winLightSettings.noLoop();
  winLightSettings.setActionOnClose(G4P.CLOSE_WINDOW);
  winLightSettings.addDrawHandler(this, "winLightSettings_draw");
  winLightSettings.addOnCloseHandler(this,"winLightSettings_OnClose");
  lstLoadLightSettings = new GDropList(winLightSettings, 10, 10, 90, 80, 3);
  lstLoadLightSettings.setItems(LightNameVisualBuffer, 0);
  lstLoadLightSettings.addEventHandler(this, "HandleDropListEvents");
  btnNewLight = new GButton(winLightSettings, 10, 100, 40, 20);
  btnNewLight.setText("New");
  btnNewLight.addEventHandler(this, "HandleButtonEvents");
  txbLEDsAmount = new GTextField(winLightSettings, 190, 40, 70, 20, G4P.SCROLLBARS_NONE);
  txbLEDsAmount.setOpaque(true);
  txbLEDsAmount.addEventHandler(this, "HandleTextboxEvents");
  lblLightsAmount = new GLabel(winLightSettings, 140, 40, 40, 20);
  lblLightsAmount.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  lblLightsAmount.setText("LEDs:");
  lblLightsAmount.setOpaque(false);
  lblLightName = new GLabel(winLightSettings, 120, 10, 60, 20);
  lblLightName.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  lblLightName.setText("Light Name");
  lblLightName.setOpaque(false);
  txbLightName = new GTextField(winLightSettings, 190, 10, 70, 20, G4P.SCROLLBARS_NONE);
  txbLightName.setOpaque(true);
  txbLightName.addEventHandler(this, "HandleTextboxEvents");
  lblPin = new GLabel(winLightSettings, 140, 70, 40, 20);
  lblPin.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  lblPin.setText("PIN:");
  lblPin.setOpaque(false);
  txbPin = new GTextField(winLightSettings, 190, 70, 70, 20, G4P.SCROLLBARS_NONE);
  txbPin.setOpaque(true);
  txbPin.addEventHandler(this, "HandleTextboxEvents");
  btnSave = new GButton(winLightSettings, 60, 100, 40, 20);
  btnSave.setText("Save");
  btnSave.addEventHandler(this, "HandleButtonEvents");
  winLightSettings.loop();
}

public void DrawFFTSpectrum()
{
  if(ready) {
  fft.forward(in.mix);
  for(int i = 1; i < 50; i++)
  {
    
    float band = fft.getBand(i)*MulBright[pointer];
    float colband = band;
    if(colband>255)
    {
      colband = 255;
    }
    
    fill(colband,255-colband,0);
    float constY = band;
    if(constY > 150) {
      constY = 150;
    }
    
    rect(10 + i*10,170,10,-constY-5);
    
  }
  }
  delay(appfps/1000);
  
  
  
}


void GetFFTData()
{
  if(ready) {
  int TableRowCount = LightSettings.getRowCount();
  for(int point = 0;point<TableRowCount;point++) {
  
  //fft.forward(in.mix);
  float bassavg = 0;
  float trebavg = 0;
  float newtreble = 0;
  
  for(int i = 1; i < 50; i++)
  {
    float band = fft.getBand(i);
    band = constrain(band,0,255);
    //RawFFT[i] = band;
  if(i>=TrebSliderValue[point] && i<=TrebSliderValue[point]+TrebArraySize[point])
    {
      
      if(Mode[point] == 0)
      {
        
       trebavg = trebavg + band;
      }
      if(Mode[point] == 1)
      {
        if(band>newtreble)
        {
          newtreble = band;
        }
      }
      
        
          
    }
    
    //BASS WORKING
    
    if(i>0 && i<=BassSliderValue[point])
    {
      bassavg = bassavg + band;
     
    }
    
  }
  if(Mode[point] == 0)
  {
    
  trebavg = trebavg / TrebArraySize[point];
  treble[point] = constrain(MulBright[point],0,255);
  bassavg = bassavg / BassSliderValue[pointer];
  bass[point] = constrain(bassavg*MulColor[point],0,255);
  }
  if(Mode[point] == 1)
  {
  treble[point] = constrain(newtreble*MulBright[point],0,255);
  bassavg = bassavg / BassSliderValue[point];
  bass[point] = constrain(bassavg*MulColor[point],0,255);
  }
  //println(bass, treble);
  
  
  
  
}
}
}

void serialEvent(Serial p) { 
  char InChar = (char)p.read();
  print(InChar);
  if(InChar == 'N' && handshake == false) {
      println("Handshake Successful!");
      handshake=true; 
      port.write('A');
      DebugTextColor = color(0,255,0);
      DebugText = "Connected.";
      btnExecute.setText("Disconnect");
      connected = true;
      //port.write("S010003015001003005007178000#");
      
    }
   
  //if(InChar == '\n')
  //{postEvent(SerialBuffer);
  //SerialBuffer = "";
 // }
 // else {
 //   SerialBuffer += InChar;
 // }
}


String normaliseint(int i)
{
  String add = "";
  String result = "";
  
  if(i<10)
  {
    add = "00";
    
  }
  if(i>=10 && i<100)
  {
    add = "0";
   
  }
  
  
  result = add+str(i);
  
  return result;
  
}

void portWrite()
{
  boolean running = true;
  while(running)
  {
  
  
  
  //println("Constr: "+constr);
  
  if(connected)
  {
  int TableRowCount = LightSettings.getRowCount();
  String constr = "";
  for(int point = 0;point<TableRowCount;point++) {
    if(treble[point]>LowPass[point]) {
    constr += "B"+normaliseint(int(bass[point]))+"T"+normaliseint(int(treble[point]));
    }
    if(treble[point]<LowPass[point]){
      constr +="B000T000";
      
    }
    
  }
  
  port.write(constr+'#');
  
  delay(1000/threadfps);
  }
  if(handshake == false) {println("No Handshake"); delay(300);}
}
}


GButton btnExecute; 
GButton btnSettings; 
GSlider2D sliMul; 
GDropList lstSelectLight; 
GDropList lstCom; 
GSlider sliBass; 
GSlider sliTreble;
GSlider sliLowPass;
GCheckbox chkMode; 
GLabel lblDebug; 
GWindow winLightSettings;
GDropList lstLoadLightSettings; 
GButton btnNewLight; 
GTextField txbLEDsAmount; 
GLabel lblLightsAmount; 
GLabel lblLightName; 
GTextField txbLightName; 
GLabel lblPin; 
GTextField txbPin; 
GButton btnSave;
GLabel lblsliBass; 
GLabel lblsliTreble;
GLabel lblsliMul;
GTextField txbTrebArraySize; 