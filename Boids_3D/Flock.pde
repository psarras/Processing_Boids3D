class Flock
{
  TFlock[] tflocks;
  Binning bin;
  ArrayList<Boid> boids;

  float separation = 2;
  float separation_distance = 30;
  float cohesion = 0.5;
  float cohesion_neighbourhood = 50;
  float alignment = 0.5;
  float alignment_neighbourhood = 50;


  Flock(int NUMBER_BOIDS, int BIN_SIZE, int NUM_THREADS)
  {
    boids = new ArrayList<Boid>();

    bin = new Binning(new int[]{BIN_SIZE, BIN_SIZE, BIN_SIZE}, 
      new float[]{(1.0 * width)/BIN_SIZE, (1.0 * height)/BIN_SIZE, (1.0 * height)/BIN_SIZE});

    for (int i = 0; i < NUMBER_BOIDS; i++)
    {
      Boid boid = new Boid(random(0, width), random(0, height), random(0, height));
      boids.add(boid);
    }

    tflocks = new TFlock[NUM_THREADS];
    int chunk = NUMBER_BOIDS / NUM_THREADS; 
    int total = chunk;
    for (int i = 0; i < NUM_THREADS; i++)
    {
      println(i * chunk, total);
      tflocks[i] = new TFlock(i * chunk, total, this);
      total += chunk;
    }
  }

  void Separation(float step)
  {
    separation += step;
  }

  void Cohesion(float step)
  {
    cohesion += step;
  }

  void Alignment(float step)
  {
    alignment += step;
  }

  void SepDist(float dist)
  {
    separation_distance += dist;
  }

  void CohesionDist(float dist)
  {
    cohesion_neighbourhood += dist;
  }

  void AlignmentDist(float dist)
  {
    alignment_neighbourhood += dist;
  }

  void update()
  {
    update(0, boids.size());
  }

  void update(int start, int finish)
  {
    bin.Update(boids);

    for (int i = start; i < finish; i++)
    {
      Boid boid = boids.get(i);
      boid.UpdateDistances(bin);
      boid.flocking(separation, separation_distance, 
        cohesion, cohesion_neighbourhood, 
        alignment, alignment_neighbourhood);
      boid.update();
      boid.wrap();
    }
  }

  void display()
  {
    for (int i = 0; i < NUMBER_BOIDS; i++)
    {
      boids.get(i).display3D();
    }
  }


  boolean running = false;

  void start()
  {
    running = true;
    for (TFlock flock : tflocks)
    {
      flock.start();
    }
  }

  void resume()
  {
    running = true;
    for (TFlock flock : tflocks)
    {
      flock.resume();
    }
  }
  void pause()
  {
    running = false;
    for (TFlock flock : tflocks)
    {
      flock.suspend();
    }
  }

  void toggle()
  {
    running = !running;
    if (running)
      resume();
    else
      pause();
  }
}
