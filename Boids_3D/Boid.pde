class Boid
{
  PVector position;
  PVector velocity;
  PVector acceleration;

  float mass = 5;
  float maxSpeed = 4;
  float maxForce = 0.2;

  float[] distances;
  ArrayList<Boid> neighbours;
  int[] id;

  Boid(float x, float y)
  {
    position = new PVector(x, y);
    velocity = new PVector(random(-1, 1), random(-1, 1));
    acceleration = new PVector();
  }

  Boid(float x, float y, float z)
  {
    position = new PVector(x, y, z);
    velocity = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
    acceleration = new PVector();
  }

  void UpdateDistances(ArrayList<Boid> boids)
  {
    distances = new float[boids.size()];
    for (int i = 0; i < boids.size(); i++)
    {
      distances[i] = dist(position, boids.get(i).position);
    }
  }

  void UpdateDistances(Binning bin)
  {
    neighbours = bin.Neighbours(this);
    distances = new float[neighbours.size()];
    for (int i = 0; i < neighbours.size(); i++)
    {
      Boid neighbour = neighbours.get(i);
      //float x = neighbour.position.x;
      try
      {
        distances[i] = dist(position, neighbour.position);
      }
      catch(Exception e) {
        //e.printStackTrace();
      }
    }
  }

  void seek(PVector target)
  {
    PVector desired = PVector.sub(target, position); //Direction to move towards
    desired.normalize(); //We are interested on the direciton only
    desired.mult(maxSpeed); //Max speed we can move
    PVector steer = PVector.sub(desired, velocity); //How much we need to turn
    steer.limit(maxForce); //How fast we can turn
    applyForce(steer); //Apply this force
  }

  PVector seekForce(PVector target)
  {
    PVector desired = PVector.sub(target, position); //Direction to move towards
    desired.normalize(); //We are interested on the direciton only
    desired.mult(maxSpeed); //Max speed we can move
    PVector steer = PVector.sub(desired, velocity); //How much we need to turn
    steer.limit(maxForce); //How fast we can turn
    return steer;
  }

  PVector Alignment(float range)
  {
    PVector sum = new PVector();
    int count = 0;
    for (int i = 0; i < neighbours.size(); i++)
    {
      Boid other = neighbours.get(i);
      float distance = distances[i];
      if ( distance > 0 && distance < range)
      {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0)
    {
      sum.setMag(maxSpeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxForce);
      return steer;
    }
    return new PVector();
  }

  PVector Cohesion(float range)
  {
    PVector sum = new PVector();
    int count = 0;
    for (int i = 0; i < neighbours.size(); i++)
    {
      Boid other = neighbours.get(i);
      float distance = distances[i];
      if (distance > 0 && distance < range)
      {
        sum.add(other.position);
        count++;
      }
    }
    if (count > 0)
    {
      sum.div(count); // Average position of our neighbours
      return seekForce(sum);
    }
    return new PVector();
  }


  PVector separate(float desiredSeparation)
  {
    int count = 0;
    PVector sum = new PVector();
    for (int i = 0; i < neighbours.size(); i++)
    {
      Boid other = neighbours.get(i);
      float distance = distances[i];
      if (distance > 0 && distance < desiredSeparation)
      {
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(distance);
        sum.add(diff);
        count++;
      }
    }
    if (count > 0)
    {
      sum.normalize(); //Direction pointing to that center
      sum.mult(maxSpeed); 
      PVector target = PVector.add(position, sum); //Target that will move us further from others
      return seekForce(target);
    } else
    {
      return new PVector();
    }
  }

  void flockingSimple(PVector target, 
    float weightSeparate, float weightTarget, float weightCohesion, float weightAlign)
  {
    PVector forceTarget = seekForce(target);
    PVector forceSeparate = separate(20 * 20);
    PVector forceCohesion = Cohesion(50 * 50);
    PVector forceAlignment = Alignment(50 * 50);

    forceTarget.mult(weightTarget);
    forceSeparate.mult(weightSeparate);
    forceCohesion.mult(weightCohesion);
    forceAlignment.mult(weightAlign);

    applyForce(forceTarget);
    applyForce(forceSeparate);
    applyForce(forceCohesion);
    applyForce(forceAlignment);
  }

  void flocking(float weightSeparate, float distance, 
  float weightCohesion, float cohesionNeighbourhood, 
  float weightAlign, float alignNeighbourhood)
  {
    PVector forceSeparate = separate(distance * distance);
    PVector forceCohesion = Cohesion(cohesionNeighbourhood * cohesionNeighbourhood);
    PVector forceAlignment = Alignment(alignNeighbourhood * alignNeighbourhood);

    forceSeparate.mult(weightSeparate);
    forceCohesion.mult(weightCohesion);
    forceAlignment.mult(weightAlign);

    applyForce(forceSeparate);
    applyForce(forceCohesion);
    applyForce(forceAlignment);
  }


  void seekAndArrive(PVector target, float stoppingDistance)
  {
    PVector desired = PVector.sub(target, position); //Direction to move towards
    //
    float distance = desired.mag();
    desired.normalize(); //We are interested on the direciton only
    if ( distance < stoppingDistance)
    {
      //Slow down
      float m = map(distance, 0, stoppingDistance, 0, maxSpeed);
      desired.mult(m);
    } else
    {
      desired.mult(maxSpeed); //Max speed we can move
    }
    PVector steer = PVector.sub(desired, velocity); //How much we need to turn
    steer.limit(maxForce); //How fast we can turn
    applyForce(steer); //Apply this force
  }

  void moveNoise(int index, float distance, float radius, float changeSpeed)
  {
    PVector forwards = new PVector(velocity.x, velocity.y);
    forwards.normalize();
    forwards.mult(distance);    
    PVector loc = PVector.add(position, forwards);
    ellipse(loc.x, loc.y, 2 * radius, 2 * radius);
    ellipse(loc.x, loc.y, 5, 5);
    noiseSeed(index);
    float x = 2 * noise(frameCount / changeSpeed) - 1;
    float y = 2 * noise((frameCount + 1000) / changeSpeed) - 1;
    PVector dir = new PVector(x, y);
    dir.normalize();
    dir.mult(radius);
    PVector target = PVector.add(loc, dir);
    ellipse(target.x, target.y, 5, 5);
    seek(target);
  }

  void applyForce(PVector force)
  {
    acceleration.add(force); //F = m * a
  }

  void update()
  {
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
    acceleration.mult(0);
  }

  void display()
  {
    fill(175);
    stroke(0);
    //ellipse(position.x, position.y, mass, mass);

    beginShape();

    PVector normalVelocity = new PVector();
    velocity.normalize(normalVelocity); //this is not changing velocity

    normalVelocity.mult(mass);
    PVector tip = PVector.add(position, normalVelocity);

    PVector rightVector = velocity.cross(new PVector(0, 0, 1));
    rightVector.normalize();
    rightVector.mult(mass/3.0);

    PVector right = PVector.add(position, rightVector);
    PVector left = PVector.add(position, rightVector.mult(-1));

    vertex(tip.x, tip.y, tip.z);
    vertex(right.x, right.y, right.z);
    vertex(left.x, left.y, left.z);
    endShape(CLOSE);
  }

  void display3D()
  {
    pushMatrix();
    translate(position.x, position.y, position.z);
    box(mass, mass, mass);
    popMatrix();
  }

  void wrap()
  {
    if (position.x >= width)
      position.x = 0;
    if (position.x < 0)
      position.x = width - 1;

    if (position.y >= height)
      position.y = 0;
    if (position.y < 0)
      position.y = height - 1;

    if (position.z >= height)
      position.z = 0;
    if (position.z < 0)
      position.z = height - 1;
  }

  void setID(int[] id)
  {
    this.id = id;
  }
}
