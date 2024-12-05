// Animation class
class Animation  {
  PImage[] frames;  //frame variable
  int currentFrame;  //current frame number variable
  float speed; // speed variable
  float lastTime;  //timer variable
  
  //constructor
  Animation(PImage[] frames, float speed) {
    this.frames = frames;
    this.currentFrame = 0;
    this.speed = speed;
    this.lastTime = millis();
  }
  
  // update function
  void update() {
    if (millis() - lastTime > speed * 1000)  {  //convert to milliseconds
      currentFrame = (currentFrame + 1) % frames.length;  //loop through frames
      lastTime = millis();
    }
  }
  
  // display function
  void display(float x, float y)  {
    PImage frame = frames[currentFrame];
    image(frame, x-frame.width/2, y-frame.height/2);
  }
}
