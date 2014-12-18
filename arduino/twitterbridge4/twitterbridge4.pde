// about
/*

//WeekEnd Project
PROJECT: TWITTER #XMAS TREE
Version 1.0.4 - 2013.01.10

//Files:
- processing: twitterbridge3.pde (twitter connection and light control)
- arduino: TwitterXMasTree.ino (hardware / software bridge)
- schema: CircuitoLuci_01.pdf (circuit)

//By Daniele Iori (hold3n)
** www.ibridodesign.com
** daniele.temp@gmail.com

//Concept IT
E' un semplice script che si connette a twitter, cerca i messaggi con la parola #xmas 
e poi invia la sequenza temporale ad arduinoo. Arduino a sua volta controlla 
la frequenza di accensione e spegnimento delle luci. 
La frequenza corrisponde ai secondi che intercorrono tra un tweet e l'altro.

Più ci si avvicina al natale, più la frequenza cresce, più uno vede fisicamente la frenesia del natale, 
fino al punto che poi l'albero 'svampa'. Proprio come le persone sotto natale.

//Concept EN
It 'a simple script connected to twitter. 
It works searching for messages with the hashtag #xmas and sending the timeline to arduino. 
So Arduino controls the frequency turning on and off the lights. 
The frequency corresponds to the seconds between a tweet and the following one.

During the days before Christmas, the frequency grows up and grows up! Until the Christmas Day! 
You can see the physical frenzy of Christmas speed up until the lights burn out!
Just like people in the home.


ATTENTION: The solution is rough and the code is dirty, but it works.


//This project uses:
** Twitter4J library - http://twitter4j.org/

//This project uses or is based on parts of:
** Simple Processing Twitter - http://robotgrrl.com/blog/2011/02/21/simple-processing-twitter/
** simpleTweet_00 processing - http://www.instructables.com/id/Simple-Tweet-Arduino-Processing-Twitter/
** Tweeting Christmas Tree - http://www.instructables.com/id/Tweeting-Christmas-Tree/
** Twitter Mention Mood Light - http://www.instructables.com/id/Twitter-Mention-Mood-Light/
** Twitter Mood Light - http://www.instructables.com/id/Twitter-Mood-Light-The-Worlds-Mood-in-a-Box


This work is licensed under a Creative Commons Attribution 3.0 - http://creativecommons.org/licenses/by/3.0/

//NEXT TO DO--------------------------------------------------------------------

// Manca la gestione 0 messaggi

// Manca la gestione pochi messaggi e di tempo precedente

// Gestire meglio la normalizzazione per medie molto basse, dove il limite di normalizzazione è troppo vicino

*/


//LIBRARIES----------------------------------------------------------------------
import processing.serial.*;

import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;

//VARIABLES

//twitter connection--------------------------------------------------------------
static String OAuthConsumerKey = "inserire qui codice";
static String OAuthConsumerSecret = "inserire qui codice";
static String AccessToken = "inserire qui codice";
static String AccessTokenSecret = "inserire qui codice";

//twitter instance----------------------------------------------------------------
Twitter twitter = new TwitterFactory().getInstance();

//Serial variables
Serial myPort;

//General-------------------------------------------------------------------------
int lastTime = 0;
int nextCall = 0;
int cumuloritardo = 0;
int frequenzamedia = 0;

//Options
int indiceritardo = (1000*1);                                    //ritardo generico del delay in secondi
int delay = 0;                                                   //init delay
String stringaDiRicerca = "#xmas";                               //stringa di ricerca
int contomessaggi = 50;                                          //init contomessaggi
int contomessaggi_base = 50;                                     //contomessaggi di riferimento
int precisione = 5;                                              //precisione della normalizzazione

//MAIN

//Setup---------------------------------------------------------------------------
void setup() {
  size(125, 125);
  frameRate(1); 
  
  background(1);
  text("TWITTER", 15, 30);
  text("BRIDGE", 15, 45);
  
  /* test serial port
  for (int i=0; i<(10); i++) {
    print(i);
    print(" - ");
    println(Serial.list()[i]);
  }
  */
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);



  connectTwitter();
}

//window---------------------------------------------------------------------------
void draw () {
  background(1);
  text("TWITTER", 15, 30);
  text("BRIDGE", 15, 45);
  


  int[] arrayPostInMillis = getSearchTweets(stringaDiRicerca);    //1 effettuo ricerca e ricavo i millis dei post
  int[] arrayFreqInSec = frequenzaInSec(arrayPostInMillis);       //2 ricavo la differenza in secondi dei tweet
  int[] arrayFreqInSecNormal = normalize(arrayFreqInSec);         //3 normalizza array secondi -> sequenza di illuminazione

  println("dati normalizzati ----");
  cumuloritardo = getTempo(arrayFreqInSecNormal);                 //4 imposta ritardo complessivo normalizzato
  frequenzamedia = cumuloritardo/contomessaggi;                   //5 imposta frequenza media
  println("media normale: " + frequenzamedia);

  stampa(arrayPostInMillis, arrayFreqInSecNormal);

  for (int i=0; i<(contomessaggi); i++) {
    impulse((arrayFreqInSecNormal[i]*indiceritardo));
    myPort.write("0");
    print("0");
  }
  
  pulsazione_limite_zero(arrayFreqInSecNormal);
  
}


//FUNCTIONS




//Connect to twitter -----------------------------------------------------
// Initial connection
void connectTwitter() {
  println("Connessione in corso");
  
  twitter.setOAuthConsumer(OAuthConsumerKey, OAuthConsumerSecret);
  AccessToken accessToken = loadAccessToken();
  long id = accessToken.getUserId();
  twitter.setOAuthAccessToken(accessToken);
  if (id != -1) {
    println("Connessione avvenuta");
    println();
  } else {
    println("Errore di connessione, controlla le credenziali: Authentication credentials (https://dev.twitter.com/pages/auth) were missing or incorrect. Ensure that you have set valid consumer key/secret, access token/secret, and the system clock is in sync.");
    exit();
  }
}

private static AccessToken loadAccessToken() {
  return new AccessToken(AccessToken, AccessTokenSecret);
}


// Search for tweets effettua una ricerca e restituisce un array con minuti e secondi in millisecondi
int[] getSearchTweets(String qstring) {

  String queryStr = qstring;
  String msgCurrent = "";
  Status t;
  java.util.Date msgCurrentDate;
  String msgCDtoString;
  String[] tmp;
  String[] minutisecondi;
  int minuti;
  int secondi;
  int millisecondi;
  int[] frequenza = new int[contomessaggi_base];

  contomessaggi = contomessaggi_base;

  try {
    // 1 imposta la ricerca
    Query query = new Query(queryStr);    
    query.setResultType(Query.RECENT);
    query.setCount(contomessaggi);

    // 2 effettua la ricerca e crea un array di risultati
    QueryResult result = twitter.search(query);    
    ArrayList tweets = (ArrayList) result.getTweets();

    // 3 estrae i millisecondi di ritardo tra un tweet e l'altro e crea un array
    for (int i=0; i<tweets.size(); i++) {                           // cicla in tutti i risultati contenuti nell'array
      t = (Status)tweets.get(i);                                    //status corrente di i
      msgCurrent = t.getText();
      msgCurrentDate = t.getCreatedAt();                             
      msgCDtoString = msgCurrentDate.toString();
      tmp = splitTokens(msgCDtoString);
      minutisecondi = split(tmp[3], ':');
      minuti = int(minutisecondi[1]);
      secondi = int(minutisecondi[2]);
      frequenza[i] =(minuti*60) + secondi;                          //frequenza è un array in millisecondi del tempo dei post

      //println(i + " - " + tmp[3] + " - " + frequenza[i]);           //stampa array con ora e millisecondi
      //println(msgCurrent);
    }                                                               //stampa numero tweet trovati
    println();
    println("Messaggi impostati: " + contomessaggi + " - tweet trovati: " + tweets.size()); 

    if (tweets.size() != contomessaggi) {                            //controllo bug twitter restituzione messaggi
      contomessaggi = tweets.size();
    }
  } 
  catch (TwitterException e) {    
    println("Search tweets: " + e);
  }
  return frequenza;
}


//esprime in secondi la sequenza di aggiornamento----------------------------------------------------------
int[] frequenzaInSec(int[] arrMillis) {
  int[] freq = new int[contomessaggi];  


  for (int i=0; i<(contomessaggi-1); i++) {
    int curr = (int) arrMillis[i];
    int prec = (int) arrMillis[i+1];

    if (curr >= prec) {
      freq[i] = curr - prec;
    } 
    else {
      freq[i] = curr + (3600 - prec);
    }
    //println(i + " - " + freq[i]);
  }
  freq[contomessaggi-1] = freq[contomessaggi-2];
  //println(contomessaggi-1 + " - " + freq[contomessaggi-1]);

  return freq;
} 


//Calcola il cumulo dei secondi--------------------------------------------------------
int getTempo(int[] arrSecondi) {
  int tempo = 0; 
  for (int i=0; i<contomessaggi; i++) {
    tempo = tempo + arrSecondi[i];
  }
  println("Cumulo ritardo: " + tempo);
  return tempo;
}



int[] normalize(int[] arrayDaNormalizzare) {
  int mediaGenerica = getTempo(arrayDaNormalizzare)/contomessaggi;
  int limite = mediaGenerica * precisione;

  for (int i=0; i<(contomessaggi); i++) {
    //print(i + " " + arrayDaNormalizzare[i] + " - ");

    if (arrayDaNormalizzare[i] >limite) {
      arrayDaNormalizzare[i] = mediaGenerica;
    }
    //println(arrayDaNormalizzare[i] + " - " + arrayNormalizzato[i]);
  }
  println("media: " +  mediaGenerica + " limite: " + limite);
  return arrayDaNormalizzare;
}


void stampa(int[] millisecondi, int[] secNormal) {

  println();
  println("i - millis - sec normal --------------------------------");
  for (int i=0; i<(contomessaggi); i++) {
    println(i + " - " + millisecondi[i] + " - " + secNormal[i] );
  }

  println("--------------------------------------------------------------");
  println();
}

void impulse(int rit) {
  if (rit==0) {
    myPort.write("1");
    print("1");
    return;
  }

  lastTime = millis();
  while (true) {
    int adesso = millis();
    if (  adesso - lastTime > rit ) { 

      //codice in delay
      myPort.write("1");
      print("1");
      return;
      //fine codice in delay
    }
  }
}

// gestione messaggi ravvicinati e frequenza di pulsazione pari a 0
void pulsazione_limite_zero(int[] arraydicontrollo){
  long ritardo = 0;
  long lasttime = 0;
  long adesso = 0;
  
  for (int i=0; i<(contomessaggi); i++){                    
    ritardo = ritardo + arraydicontrollo[i];                      //faccio la somma del tempo di pulsazione
  }
  if (ritardo < contomessaggi){                                   //verifico se è minore del numero dei messaggi
    ritardo = contomessaggi_base - ritardo;                       //prevedendo una pulsazione da un secondo 
    println();                                                    //aggiungo quello che manca per arrivare a 1 sec a messaggio
    print("Ritardo aggiuntivo: " + ritardo +"s ");
    ritardo = ritardo*1000;                                       //trasformo in millisecondi
    
    lasttime = millis();                                          //creo un delay
    while(true){
      adesso = millis();
      //print(".");
      if (adesso-lasttime > ritardo) {
        return;
      }
    }  
  }
}






