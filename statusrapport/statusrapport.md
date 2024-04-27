Denna fil är skriven med [MarkDown](https://www.markdownguide.org/basic-syntax/)

Uppdatera statusrapporten **senast** kl 12 varje tisdag, enligt Leveranser VT2 i Lisam 

# Satusrapport Grupp *XY*
Svara på följande frågor i tidrapporten varje vecka:
1. Vilka framsteg har gjorts sedan förra tidrapporten?
2. Finns det några problem?
3. Vad ska göras kommande vecka?

---

## Statusrapport för Vecka 13 (*Mikael*) (rapporteras tisdag v14)
1. Den gångna veckan har vi arbetat med kompletteringar kring designspecifikationen och funderat på vilka adresseringsmoder vi vill använda oss av i projektet.
2. Just nu korrigerar vi de sista kompletteringarna i designspecifikationen och har påbörjat arbetet med cpu:ns vhdl-fil. Inga påtagliga problem har framträdit än.  
3. Kommande vecka tänker vi jobba med:
	- Christoffer : Skriva vhdl kod för CPU:n
	- Mikael : Hjälper Christoffer med upplägget och designen av vhdl-koden.
	- Hugo : Påbörjat arbetet med microkoden.
	- Edvard : Samarbetar med Hugo.

## Statusrapport för Vecka 14 (*Hugo*) (rapporteras tisdag v15)
1. Vilka framsteg har gjorts sedan förra tidrapporten?
Sedan föregående statusrapport har ytterliggare komponenter lagts till i processorn. Dessa komponenter är Timern och en "Random"-generator för att generera slumpmässiga koordinater där äpplet ska placeras ut på spelplanen.
2. Finns det några problem?
Standardbiblioteken fungerar inte som tänkt och innebär att vissa syntaktiska kortvägar inte fungerar. 
3. Vad ska göras kommande vecka?
Kommande vecka ska implementeringen av processorns olika delar fortgå. Vi ska skriva testbänk för att testa och buggfixa koden. 

## Statusrapport för Vecka 15 (*Hugo*) (rapporteras tisdag v16)
1. Vilka framsteg har gjorts sedan förra tidrapporten?
Koden har uttökats och en testbänk för att testa processorn har tillkommit. Edvard har skrivit microkod i excel som Hugo nu överfört in i microMinnnet. Även K1 har ändrats för att korrekt återge den rad i uM då varje instruktion börjar.
2. Finns det några problem?
Problem med syntax kvarstår, dessutom kvarstår en mängd buggar genom texten. Instruktionerna i uM är ännu otestade och det är oklart ifall de faktiskt fungerar.
3. Vad ska göras kommande vecka?
Testbänk skall färdigställas, och koden skall testas. De sista instrukionerna måste översättas till microkod och skrivas in i microminnet och K1.

## Statusrapport för Vecka 16 (*Hugo*) (rapporteras tisdag v17)
1. Vilka framsteg har gjorts sedan förra tidrapporten?
Det som stod under punkt 3 i föregående statusrapport har gjorts. Alltså finns nu testbänk och alla planerade instruktioner är implementerade och införda i projektet. Dessutom har Mikael skrivit koden för Joysticken.
2. Finns det några problem?
Det är ännu inte helt klart i vilket utsträckning den skrivna koden fungerar. Fortsatt testning av koden krävs.
3. Vad ska göras kommande vecka?
Fler tester. Dessutom ska det gå att få upp något grafiskt på skärmen. 


## Statusrapport för Vecka 17 (*Hugo*) (rapporteras tisdag v18)
1. Vilka framsteg har gjorts sedan förra tidrapporten?
Ytterliggare framsteg har gjorts med testerna till ALUn och CPUn. VGA_MOTORN, Grafik-komponenten och Bild-minnet är i princip och väntar på testning.
2. Finns det några problem?
Nej. Det är endast fortsatt implementation av de olika delarna som behövs.
3. Vad ska göras kommande vecka?
Få en bild på skärmen och färdigställa alla komponenter.


## Statusrapport för Vecka 18 (*Mikael*) (rapporteras tisdag v19)
1. Vilka framsteg har gjorts sedan förra tidrapporten?
Vi har lyckats lista ut hur det går till att koppla in de vhdl-kodfilerna vi har skapat in i den faktiska fysiska komponenten. Till exempel passeras joystick:ens fysiska in och output signaler genom uprogCPU-filen som sedan vidarebefodrar dessa in i de andra filerna.
2. Finns det några problem?
Det vi får upp på skärmen vid körning reflekterar inte det som vi förväntar oss med take på hur vi har byggt upp bildminnet och tile-blocken.
3. Vad ska göras kommande vecka?
Vi tror att det tidigare nämnda problemet har sitt ursprung i VGA_MOTOR:n. Därför kommer vi fokusera på att felsöka grafiken. Om vi hinner bli klara innan veckan är över ska vi se om vi får in och ut data från joysticken.

## Statusrapport för Vecka 19 (*rapportör*) (rapporteras tisdag v20)
*Presentation av projekt tisdag/onsdag*

## Statusrapport för Vecka 20 (*rapportör*) (rapporteras tisdag v21)
*Nu jobbar vi övertid ...*
