//////////////////////////////////////////////////////////////////////////////////////////
// InfoSNAKE
// ---------
// This Program is an interpretation of the original SNAKE-game for educational purposes.
// All images and sounds used are public domain:  
//  * jelly.png -- https://commons.wikimedia.org/wiki/File:Food-Jelly.svg?uselang=de
//  * 206016__junkfood2121__liquid-fill-glass.mp3 
//       -- http://www.freesound.org/people/junkfood2121/sounds/206016/ (converted to mp3)
//
//
// License: GPLv3.0
// F. Kick DBG Eppelheim
//////////////////////////////////////////////////////////////////////////////////////////


// Noch zu verbessern:
// (1) Neue Food-Koordinaten können im Körper der Schlange liegen
// (2) Richtungsänderung um 180° ist möglich, wenn man innerhalb einer 1/10 Sekunde 
//     erst um 90° und dann erneut um 90° dreht. 
// (3) Beim Fressen des Puddings soll ein Sound erklingen
// (4) Während dem Spiel soll der Punktestand eingeblendet werden
// (5) Das Aussehen des FOODS soll sich nach jedem gefressen werden ändern
// (6) Die Farbe der Körperteile soll vom Kopf ausgehend immer blasser werden




///// VARIABLEN //////////////////////////////////////////////////////////////////////////

// ALLGEMEINE EINSTELLUNGEN
int schrittweite = 25;
int SpielfeldGroesseX = 30;
int SpielfeldGroesseY = 30;

// SPIELER (SNAKE)
int[] x = new int[SpielfeldGroesseX*SpielfeldGroesseY];
int[] y = new int[SpielfeldGroesseX*SpielfeldGroesseY];
int score=0;    // Punktestand
int tailLenght=2;    // Länge der Schlange
boolean dead=false;  // Lebt die Schlange noch?
int vx=0;       // Geschwindigkeit in x-Richtung
int vy=-1;      // Geschwindigkeit in y-Richtung
                // Start nach oben, denn vy<0


// ZIELOBJEKT (FOOD) 
int foodX=int(random(1,SpielfeldGroesseX-1));
int foodY=int(random(1,SpielfeldGroesseY-1));
PImage foodImage;
int foodsize;   // Größe des Bildes




//////  KONSTRUKTOR  ////////////////////////////////////////////////////////////////////////// 
void setup() {
  size(SpielfeldGroesseX*schrittweite,SpielfeldGroesseY*schrittweite);
  background(255);
  noStroke();
  rectMode(CENTER);
  textAlign(CENTER);
  imageMode(CENTER);
  foodImage = loadImage("jelly.png");  
  frameRate(10);
  x[0]=int(random(1,SpielfeldGroesseX-1));
  y[0]=int(random((SpielfeldGroesseY-1)/2,SpielfeldGroesseY-1));
  x[1]=x[0];
  y[1]=y[0]-vy;
  foodsize = schrittweite;
}



//////  LOOP  /////////////////////////////////////////////////////////////////////////////////
void draw() {
  if (dead==false) {                  // Solange das Spiel läuft...
    background(255);
    zeichneFood();
    bewegeSchlange(tailLenght);
    kollisionsKontrolle();
    punkteKontrolle();
  } else {                            // Wenn der Spieler tot ist...
    fill(150,100);
    rect(width/2,height/2,width,height);
    textSize(100);
    fill(20);
    text("GAME OVER",width/2,height/2);
    textSize(30);
    fill(120);
    text("SCORE: "+(score),width/2,2*(height/3)+50);
    noLoop(); // beendet die Endlosschleife (d.h. die draw()-Methode wird nun nicht mehr aufgerufen)
  }
}

// Processing-Methode, die die Tastatur überwacht. 
// Wird unabhängig vom Loop getriggert. 
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      if(vy!=1) {
        vy=-1;
        vx=0;
      }
    } else if (keyCode == DOWN) {
      if(vy!=-1) {
        vy=1;
        vx=0;
      }
    } else if (keyCode == LEFT) {
      if(vx!=1) {
        vx=-1;
        vy=0;
      }
    } else if (keyCode == RIGHT) {
      if(vx!=-1) {
        vx=1;
        vy=0;
      }
    } 
  } 
}




/////  METHODEN  //////////////////////////////////////////////////////////////////////////

// Diese Methode arbeitet rekursiv: Es wird immer das n-te Körperteil bewegt. Dies ist 
// jeweils ein Kopiervorgang, denn das letzte Körperteil erhält die Koordinaten des 
// vorletzten Körperteils, das vorletzte die Koordinaten des vorvorletzten usw. 
// Erst der Kopf wird schließlich in die aktuelle Richtung bewegt. 
// Aufgerufen wird die Methode im Loop mit bewegeSchlange(<Länge der Schlange>). Dadurch
// wird das letzte Körperteil der Schlange bewegt und die Methode für so lange für das 
// vorhergehende Körperteil aufgerufen, bis der Kopf erreicht ist. 
void bewegeSchlange(int n) {
  if (n>=1) {
    // Bewegen eines Körperteils
    x[n] = x[n-1];
    y[n] = y[n-1];
    bewegeSchlange(n-1);
  } else {
    // Bewegen des Kopfes
    x[0] = x[0]+vx;
    y[0] = y[0]+vy;
  }
  // Zeichnen des Körperteils
  fill(70,110,200);
  rect((x[n]*schrittweite)+1,(y[n]*schrittweite)+1,schrittweite-2,schrittweite-2);
}



// Sind wir gegen eine Wand oder uns selbst gelaufen?
void kollisionsKontrolle(){
  if (x[0]<=0 || x[0]>=SpielfeldGroesseX || y[0]<=0 || y[0]>=SpielfeldGroesseY) {
    dead = true;
  }
  for (int n=1; n<tailLenght; n++) {
    if (x[0]==x[n] && y[0]==y[n] ) {
      dead = true;     
    }
  }
}


// Gibt es Punkte?
void punkteKontrolle(){
  if ( foodX == x[0] && foodY == y[0] ) {
    score++; 
    tailLenght++;
    // Das Food soll noch nicht direkt neue Koordinaten erhalten, sondern zunächst
    // als Erfolgssignal wachsen. In der Methode zeichneFood() wird die Größe des Foods
    // überwacht - ist es größer als die Schrittweite, so wächst es weiter bis zu einer
    // Grenze, ab dort wird die Größe zurückgesetzt und neue Koordinaten erwürfelt. 
    foodsize=int(foodsize*1.4);    
  }
}

// Zeichnet das Food
void zeichneFood() {
  // Falls das Food gerade gefressen wurde, soll es wachsen...
  if (foodsize!=schrittweite) {
      if (foodsize<schrittweite*5) {
        foodsize=int(foodsize*1.4);
      } else { // ... bis es die maximale Größe erreicht hat. 
        // dann soll es wieder auf die normale Größe schrumpfen und
        foodsize=schrittweite;
        // neue Koordinaten erhalten
        neueFoodKoordinaten(tailLenght);
      }
    }
    image(foodImage, foodX*schrittweite,foodY*schrittweite, foodsize, foodsize);
}

// Ordnet dem Food neue Koordinaten zu
void neueFoodKoordinaten(int n) {
    foodX=int(random(1,SpielfeldGroesseX-1));
    foodY=int(random(1,SpielfeldGroesseY-1));
}  

    

// Beendet das Programm (nur wg. Sounds nötig). 
void stop()
{
  super.stop();
}

///// EOF (End of File) ////////////////////////////////////////////////////////////////
