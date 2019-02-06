class Binning
{
  float[] size;
  int[] dim;
  ArrayList<Boid>[][][] bin;

  Binning(int[] dim, float[] size)
  {
    this.dim = dim;
    this.size = size;
    bin = new ArrayList[dim[0]][dim[1]][dim[2]];

    for (int i = 0; i < dim[0]; i++)
    {
      for (int j = 0; j < dim[1]; j++)
      {
        for (int k = 0; k < dim[2]; k++)
        {
          bin[i][j][k] = new ArrayList<Boid>();
        }
      }
    }
  }

  int[] position(PVector pos)
  {
    int[] ids = new int[3];
    ids[0] = min(dim[0], max(0, (int)(pos.x / size[0])));
    ids[1] = min(dim[1], max(0, (int)(pos.y / size[1])));
    ids[2] = min(dim[2], max(0, (int)(pos.z / size[2])));
    return ids;
  }

  void Update(ArrayList<Boid> boids)
  {
    for (int i = 0; i < dim[0]; i++)
    {
      for (int j = 0; j < dim[1]; j++)
      {
        for (int k = 0; k < dim[2]; k++)
        {
          ArrayList<Boid> b = bin[i][j][k];
          b.clear();
        }
      }
    }
    
    for (Boid other : boids)
    {
      int[] id = position(other.position);
      other.setID(id);
      ArrayList<Boid> b = bin[id[0]][id[1]][id[2]];
      b.add(other);
    }
  }

  ArrayList<Boid> Neighbours(Boid boid)
  {
    ArrayList<Boid> boids = new ArrayList<Boid>();

    int[] id = boid.id;

    for (int i = -1; i <= 1; i++)
    {
      for (int j = -1; j <= 1; j++)
      {
        for (int k = -1; k <= 1; k++)
        {
          int[] _id = new int[]{id[0] + i, id[1] + j, id[2] + k};
          if (_id[0] >= 0 && _id[0] < dim[0] &&
            _id[1] >= 0 && _id[1] < dim[1] &&
            _id[2] >= 0 && _id[2] < dim[2])
          {
            ArrayList<Boid> b = bin[_id[0]][_id[1]][_id[2]];
            if(b != null)
              boids.addAll(b);
          }
        }
      }
    }

    return boids;
  }
}
