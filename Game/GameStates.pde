public interface State{
  public void on_update(float dt, PApplet pa);
  public void on_draw(PGraphics pg, PApplet pa);
  public void on_begin(PApplet pa);
  public void on_end(PApplet pa);
  public void on_pause(PApplet pa);
  public void on_resume(PApplet pa);
}

public class GameState implements State {
  
  
  
  public void on_update(float dt, PApplet pa){
    
  }
  
  public void on_draw(PGraphics pg, PApplet pa)
  {
  }
  
  public void on_begin(PApplet pa)
  {
  }
  
  public void on_end(PApplet pa)
  {
  }
  
  public void on_pause(PApplet pa)
  {
  }
  
  public void on_resume(PApplet pa)
  {
  }
}

public class MenuState implements State {
    public void on_update(float dt, PApplet pa){
    
  }
  
  public void on_draw(PGraphics pg, PApplet pa)
  {
    
  }
  
  public void on_begin(PApplet pa)
  {
    
  }
  
  public void on_end(PApplet pa)
  {
    
  }
  
  public void on_pause(PApplet pa)
  {
    
  }
  
  public void on_resume(PApplet pa)
  {
    
  }
}