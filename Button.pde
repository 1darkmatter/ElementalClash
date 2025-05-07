/* Button.pde
 * Elemental Clash – Button UI element
 * Provides a standard interactive button for menus and game controls.
 */
class Button{
  float x, y, w, h;
  String label;
  boolean enabled = true, visible = true;
  color fillColor = #DCDCDC, hoverColor = #ADD8E6, disabledColor = #A9A9A9,
        strokeColor = #000000, textColor = #000000, disabledTextColor = #696969;
  float strokeW = 1.5f, corner = 8, txtSize = 14;
  Button(float X, float Y, float W, float H, String L){
    x = X;
    y = Y;
    w = W;
    h = H;
    label = L;
  }

  boolean isMouseOver(){
    return visible && enabled && mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  void display(){
    if(!visible) return;

    pushStyle(); 
    color bg;
    if(!enabled) {
        bg = disabledColor;
    } else if (isMouseOver()) {
        bg = hoverColor;
    } else {
        bg = fillColor;
    }

    fill(bg);
    stroke(strokeColor); 
    strokeWeight(strokeW);
    rect(x, y, w, h, corner);

    fill(enabled ? textColor : disabledTextColor);
    textSize(txtSize); 
    textAlign(CENTER, CENTER);
    text(label, x + w/2, y + h/2);
    popStyle(); 
  }
}
