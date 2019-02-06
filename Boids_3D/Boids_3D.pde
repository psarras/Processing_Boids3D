/*
Author: Stamatios Psarras
Based on: Daniel Shiffman's code on the nature of code.

This is a boids 3D algorithm with separation, cohesion, alignment.
It has been modified to optimize the distance calculation 
by using the square distance. Furthermore, multiple threads can be used 
to separate the drawing from the calculation and spread the load over 
multiple cores.

Please see licence included for details
*/

int NUMBER_BOIDS = 15000;
int BIN_SIZE = 20;
int NUM_THREADS = 3;

Flock flock;

void setup()
{
  size(1200, 800, P3D);

  frameRate(1000);
  noStroke();
  flock = new Flock(NUMBER_BOIDS, BIN_SIZE, NUM_THREADS);
  flock.start();
}

void draw()
{
  background(50);

  translate(0, 0, -height);

  if (inThread)
    flock.update();
  if (!hide)
    flock.display();
  //println(frameRate);
}

boolean hide = false;
boolean running = true;
boolean inThread = false;

void keyPressed()
{
  //Calculations
  if (key == 'h')
    hide = !hide;

  if (key =='r')
    flock.toggle();
  if (key =='t')
    inThread = !inThread;

  //Behaviour
  float step = 0.1;
  if (key == 'S')
    flock.Separation(step);
  else if (key == 's')
    flock.Separation(-step);
  if (key == 'C')
    flock.Cohesion(step);
  else if (key == 'c')
    flock.Cohesion(-step);
  if (key == 'A')
    flock.Alignment(step);
  else if (key == 'a')
    flock.Alignment(-step);

  float dist = 10;
  if (key == 'D')
    flock.SepDist(dist);
  else if (key == 'd')
    flock.SepDist(-dist);
  if (key == 'N')
    flock.CohesionDist(dist);
  else if (key == 'n')
    flock.CohesionDist(-dist);
  if (key == 'M')
    flock.AlignmentDist(dist);
  else if (key == 'm')
    flock.AlignmentDist(-dist);
  //ALIGNMENT_NEIGHBOURHOOD -= dist;

  println("Seperation: ", flock.separation, 
    "Sep Distance: ", flock.separation_distance, 
    "Cohesion: ", flock.cohesion, 
    "Coh Neighbourhood: ", flock.cohesion_neighbourhood, 
    "Alignment", flock.alignment, 
    "Align Neighbourhood: ", flock.alignment_neighbourhood
    );
}
