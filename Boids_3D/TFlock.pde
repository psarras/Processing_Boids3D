class TFlock extends Thread
{
  boolean running = true;
  int start;
  int finish;
  int cycles = 0;
  Flock flock;
  
  TFlock(int start, int finish, Flock flock)
  {
    this.start = start;
    this.finish = finish;
    this.flock = flock;
  }

  public void run()
  {
    while (running)
    {
      cycles++;
      
      flock.update(start, finish);

      try
      {
        Thread.sleep(0);
      }
      catch(InterruptedException e) {
        e.printStackTrace();
      }
    }
  }

  void quit()
  {
    running = false;
    interrupt();
  }
}
