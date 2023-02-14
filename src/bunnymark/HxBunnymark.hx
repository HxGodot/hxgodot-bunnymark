package bunnymark;

import godot.*;
import godot.variant.*;
import godot.core.*;

class HxBunnymark extends Node2D {
    
    var grav = 500.0;
    var bunny_texture:Texture2D;
    var bunny_speeds:Array<Vector2> = [];
    var label = new Label();
    var bunnyRoot = new Node2D();
    var bunnies:Array<Node2D> = [];
    var screen_size:Vector2;

    override function _ready() {
        if (Engine.singleton().is_editor_hint()) return;

        bunny_texture = ResourceLoader.singleton().load("res://scenes/wabbit_alpha.png", "", 1).as(Texture2D);

        add_child(bunnyRoot);

        label.set_position(new Vector2(0, 20));
        add_child(label);
    }

    override function _process(delta:Float) {
        screen_size = get_viewport_rect().size;        

        for (i in 0...bunnies.length) {
            var bunny = bunnies[i];
            var pos = bunny.position;
            var speed = bunny_speeds[i];
            
            pos.x += speed.x * delta;
            pos.y += speed.y * delta;
        
            speed.y += grav * delta;
        
            if (pos.x > screen_size.x) {
                speed.x *= -1;
                pos.x = screen_size.x;
            }
            
            if (pos.x < 0) {
                speed.x *= -1;
                pos.x = 0;
            }
                
            if (pos.y > screen_size.y) {
                pos.y = screen_size.y;
                if (Math.random() > 0.5)
                    speed.y -= 30 + Math.random() * 1000;
                else
                    speed.y *= -0.85;
            }
                
            if (pos.y < 0) {
                speed.y = 0;
                pos.y = 0;
            }
            
            bunny.position = pos;
            bunny_speeds[i] = speed;
        }
    }

    @:export public function add_bunny() {
        var bunny = new Sprite2D();
        bunny.set_texture(bunny_texture);
        bunnies.push(bunny);
        bunnyRoot.add_child(bunny);
        bunny.position = new Vector2(screen_size.x / 2, screen_size.y / 2);
        bunny_speeds.push(new Vector2(GDUtils.randi() % 200 + 50, GDUtils.randi() % 200 + 50));

        label.text = "Bunnies: " + bunnies.length;
    }

    @:export public function remove_bunny() {

        if (bunnies.length == 0) return;
        bunny_speeds.pop();
        var bunny = bunnies.pop();
        bunnyRoot.remove_child(bunny);
        bunny.queue_free();
        
        label.text = "Bunnies: " + bunnies.length;
    }

    @:export public function finish() {
        emit_signal("benchmark_finished", bunnies.length);
    }
}