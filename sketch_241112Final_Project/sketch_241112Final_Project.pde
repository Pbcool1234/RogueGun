// paul brabson
//this code creates a player that can move and shoot bullets at the enemy.
//if the bullet hits the enemy, the enemy will disappear.
//if the enemy touches the player, the player will disappear.
//background music now plays on a loop.
//there are bullet sounds each time a bullet is fired.
//the obstacles can hurt the player - running into an obstacle will kill the player
//There are 3 levels generated randomly - desert, snowy mountain, and grassy plain
//The game continues until the player dies.

// import sound lib
import processing.sound.*;

// Global Variables
Player player;  // player variable
Enemy enemy;  // enemy variable
ArrayList<Enemy> enemies;  //list of enemies
ArrayList<Bullet> bullets; //list of bullets
ArrayList<Obstacle> obstacles;  //list of obstacles
SoundFile backGroundMusic;  // background music
SoundFile bulletSound;  // sound of bullet
PImage rangerImage;  //main player image

// Images for different levels
PImage cactus1Image, enemy1Image; // Desert
PImage rockImage, yetiImage;      // Snow
PImage shrubImage, buffaloImage; // Field

// Level Properties
int currentLevel; // 0 = Desert, 1 = Snow, 2 = Field
int screen = 3; // 0 = game over, 1 = SwitchLevelScreen , 2 = game screen, 3 = title screen
PFont titleFont, instructionFont;  // fonts for title screen

// Animation Variables
PImage[] fireWorkFrames; // array of image frames
Animation fireWorkAnimation;  //animation variable

  

void setup() {
  size(800, 800);
  
  //load fonts
  titleFont = createFont("Arial", 48);
  instructionFont = createFont("Arial", 24);
  
  // Load images
  rangerImage = loadImage("ranger.png");
  cactus1Image = loadImage("cactus1.png");
  enemy1Image = loadImage("enemy1.png");
  rockImage = loadImage("rock.png");
  yetiImage = loadImage("yeti.png");
  shrubImage = loadImage("shrub.png");
  buffaloImage = loadImage("buffalo.png");

  // Initialize game objects
  initializeLevel(randomLevel());

  // Load sound files
  backGroundMusic = new SoundFile(this, "1415_dhol-drums-01.mp3");
  bulletSound = new SoundFile(this, "1418_gunshot-01.mp3");
  backGroundMusic.loop();  // Play music on loop
  
   //load frames
  fireWorkFrames = new PImage[5];
  for (int i = 0; i < fireWorkFrames.length; i++) {
    fireWorkFrames[i] = loadImage("data/blackfirework" + i + ".png");
  }
  fireWorkAnimation = new Animation(fireWorkFrames, 0.1);
}

void draw() {
  //SCREENUPDATE
  if (screen == 0) {
    gameOver();  // death screen
  }  else if (screen == 1)  {
    congratScreen();  // transition screen
  }  else if (screen == 2)  {
    playGame();  // main game screen
  }  else if (screen == 3)  {
    displayTitleScreen();  // title screen
  }
}

//function to show title screen
void displayTitleScreen()  {
  background(0); //light blue background
  
  //title
  PImage titleImage = loadImage("roguegun.png"); //title image variable - created with Canva
  imageMode(CENTER);
  image(titleImage, width/2, height/3);
  
  //instructions
  textFont(instructionFont);
  text("Use WASD to move the Ranger.", width/3-120, height/2+140);
  text("Enemies will follow you. Shoot them with Spacebar.", width/3-120, height/2+170);
  text("Your shooting direction is the direction you last moved in.", width/3-120, height/2+200);
  text("Avoid obstacles like cacti, rocks, and tall grass.", width/3-120, height/2+230);
  text("Press any key to continue.", width/3-120, height/2+260);
}

void playGame() {
   // Set the background based on the level
  if (currentLevel == 0) {
    background(237, 201, 175); // Desert
  } else if (currentLevel == 1) {
    background(255); // Snow
  } else if (currentLevel == 2) {
    background(180, 255, 180); // Field
  }

  // Player
  if (player != null) {
    player.display();
    player.move();

    // Check collision with enemies
    for (int i = enemies.size() - 1; i >= 0; i--)  {
      if (player.collisionCheck(enemies.get(i))) {
        player = null; // Player disappears
        println("Player collided with enemy!");
        return;
      }
    }

    // Check collision with obstacles
    for (Obstacle obstacle : obstacles) {
      if (player != null && player.collisionCheck(obstacle)) {
        player = null; // Player disappears
        println("Player collided with obstacle!");
        break;
      }
    }
  } else {
    screen = 0;
    return;
  }

  // Enemies
  for (int i = enemies.size() - 1; i >= 0; i--)  {
    Enemy enemy = enemies.get(i);
    enemy.display();
    enemy.moveTowards(player);
    
    //check for bullet collision
    for (int j = bullets.size() - 1; j >= 0; j--)  {
      Bullet b = bullets.get(j);
      if (b.collisionCheck(enemy))  {
        bullets.remove(j);  //remove bullet
        enemies.remove(i);  //remove enemy
        println("Enemy hit!");
        break;
      }
    }
  }
  
  //go to next level if all enemies defeated
  if (enemies.isEmpty())  {
    screen = 1;  //transition screen
    return;
  }

  // Bullets
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.display();
    b.move();
    if (b.offscreenCheck()) {
      bullets.remove(i); // Remove bullet if offscreen
    }
  }

  // Display obstacles
  for (Obstacle obstacle : obstacles) {
    obstacle.display();
  }
}

void keyPressed() {
  if (screen == 1 && key == ' ')  {
    screen = 2;  //switch to game screen
    initializeLevel(randomLevel());  //start next level
  } else if (screen == 2 && key == ' ') {
    bullets.add(new Bullet(player.x, player.y, player.lastXDir, player.lastYDir));
    bulletSound.play(); // Play sound when bullet is fired
  }  else if (screen == 3)  {
    screen = 2;
  }
}

//Screen between Levels
void congratScreen() {
  background(240, 240, 240);
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(0);
  text("Congratulations!", width/2, height/2-40);
  text("Press space to continue", width/2, height/2+20);

  //animate
  if (screen == 1){  
    fireWorkAnimation.update();
    fireWorkAnimation.display(width/2+90, height/2+200);  // put in center
  }

  
}

//function to make sure no object overlaps player
//ensures positions is at least safeDistance away from player
//PVector information learned from Processing documentation
PVector generatePosition(float safeDistance)  {
  float x, y;  // x and y position
  do {
    x = random(50, width-50);
    y = random(50, height-50);
  }  while (dist(x, y, width/2, height/2) < safeDistance);
  return new PVector(x, y);
}

// Initialize the current level
void initializeLevel(int levelType) {
  currentLevel = levelType;  //set current level to level type
 // screen = 2;  //set to game mode
  player = new Player(width / 2, height / 2);  // player variable
  bullets = new ArrayList<Bullet>();  //list of bullets
  obstacles = new ArrayList<Obstacle>(); //list of obstacles
  enemies = new ArrayList<Enemy>(); //list of enemies
  float safeDistance = 50; //min distance from player

  if (currentLevel == 0) { // Desert
    for (int i = 0; i < 3; i++) { // Generate 3 enemies
      PVector enemyPos = generatePosition(safeDistance);
      enemies.add(new Enemy(enemyPos.x, enemyPos.y, enemy1Image));
    }
    for (int i = 0; i < 5; i++) {
      PVector obstaclePos = generatePosition(safeDistance);
      obstacles.add(new Obstacle(obstaclePos.x, obstaclePos.y, cactus1Image));
    }
  } else if (currentLevel == 1) { // Snow
    for (int i = 0; i < 3; i++) { // Generate 3 enemies
      PVector enemyPos = generatePosition(safeDistance);
      enemies.add(new Enemy(enemyPos.x, enemyPos.y, yetiImage));
    }
    for (int i = 0; i < 5; i++) {
      PVector obstaclePos = generatePosition(safeDistance);
      obstacles.add(new Obstacle(obstaclePos.x, obstaclePos.y, rockImage));
    }
  } else if (currentLevel == 2) { // Field
    for (int i = 0; i < 3; i++) { // Generate 3 enemies
      PVector enemyPos = generatePosition(safeDistance);
      enemies.add(new Enemy(enemyPos.x, enemyPos.y, buffaloImage));
    }
    for (int i = 0; i < 5; i++) {
      PVector obstaclePos = generatePosition(safeDistance);
      obstacles.add(new Obstacle(obstaclePos.x, obstaclePos.y, shrubImage));
    }
  }
}

// Generate a random level
int randomLevel() {
  return int(random(3)); // Returns 0, 1, or 2
}

// Game Over
void gameOver() {
  background(0);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Game Over!", width / 2, height / 2);
  noLoop(); // Stop the game loop
}

// Obstacle class
class Obstacle {
  float x, y;
  float size = 30;
  PImage sprite;

  Obstacle(float x, float y, PImage sprite) {
    this.x = x;
    this.y = y;
    this.sprite = sprite;
  }

  void display() {
    imageMode(CENTER);
    image(sprite, x, y, size, size);
  }
}

//player class
class Player  {
  float x, y;  //x and y position
  float size = 30;  //diameter of player
  float lastXDir = 0;  // intitial x direction
  float lastYDir = -1; // initial facing direction upward
  float speed = 2;  //speed of player
  
  //constructor
  Player(float x, float y)  {
    this.x = x;
    this.y = y;
  }
  
  //display function
  void display()  {
    //fill(0, 255, 0); //Player color - Green
    //ellipse(x, y, size, size);
    imageMode(CENTER);
    image(rangerImage, x, y, size, size);
  }
  
  //move function
  void move() {
    
    //initialize movement to zero
    float xmove = 0;
    float ymove = 0;
    
    //set key directions
    if (keyPressed)  {
      if (key == 'w' && y - speed - size/2 >= 0)  {  //move up
        y = y - speed;
        lastXDir = 0;
        lastYDir = -1;
      }
      if (key == 's' && y + speed + size/2 <= height)  {  //move down
        y = y + speed;
        lastXDir = 0;
        lastYDir = 1;
      }
      if (key == 'a' && x - speed - size/2 >= 0)  {  //move left
        x = x - speed;
        lastXDir = -1;
        lastYDir = 0;
      }
      if (key == 'd' && x + speed + size/2 <= width)  {  //move right
        x = x + speed;
        lastXDir = 1;
        lastYDir = 0;
      }
    }
    
    //update position
    x = x + xmove;
    y = y + ymove;
  }
  
  // Collision Check Function
  boolean collisionCheck(Enemy e)  {  //check to see if enemy catches player
    if (e != null)  {
      float distance = dist(x, y, e.x, e.y);
      if (distance < (size/2 + e.size/2))  return true;
    }
    return false;
  }
  
  // Collision Check Function
  boolean collisionCheck(Obstacle c)  {  //check to see if player runs into Obstacle
    if (c != null)  {
      float distance = dist(x, y, c.x, c.y);
      if (distance < (size/2 + c.size/2))  return true;
    }
    return false;
  }
  
  //check if offscreen
  boolean offscreenCheck()  {
    if (x < 0 || x > width || y < 0 || y > height)  return true;
    else return false;
  }
}

//Enemy class
class Enemy  {
  float x, y;  //x and y position of enemy
  float size = 30; // diameter of enemy
  float speed = 0.7; //speed of enemy
  PImage sprite;  //image of enemy
  
  //constructor
  Enemy(float x, float y, PImage sprite)  {
    this.x = x;
    this.y = y;
    this.sprite = sprite;
  }
  
  //display function
  void display()  {
    imageMode(CENTER);
    image(enemy1Image, x, y, size, size);
  }
  
  //move towards player function
  void moveTowards(Player p)  {
    if (p != null) { //do this if player exists
      if (x < p.x)  x = x + speed;
      if (x > p.x)  x = x - speed;
      if (y < p.y)  y = y + speed;
      if (y > p.y)  y = y - speed;
    }
  }
}

//bullet class
class Bullet {
  float x, y;  //x and y position of bullet\
  float size = 10;  // diameter of bullet
  float speed = 5;  //speed of bullet
  float xSpeed, ySpeed; // speed in x and y
  
  //constructor
  Bullet(float startX, float startY, float xDir, float yDir)  { //X and Y start position and and bullet direction
    x = startX;
    y = startY;
    xSpeed = xDir * speed;
    ySpeed = yDir * speed;
  }
  
  // display function
  void display()  {
    fill(0, 0, 0);  // color of bullet - blue
    ellipse(x, y, size, size);
  }
  
  //move function
  void move() {
    x = x + xSpeed;
    y = y + ySpeed;
  }
  
  //check for collision with enemy
  boolean collisionCheck(Enemy e)  {  //check to see if bullet hits enemy
    if (e != null)  {
      float distance = dist(x, y, e.x, e.y);
      if (distance < (size/2 + e.size/2))  return true;
    }
    return false;
  }
  
  //check if offscreen
  boolean offscreenCheck()  {
    if (x < 0 || x > width || y < 0 || y > height)  return true;
    else return false;
  }
}
