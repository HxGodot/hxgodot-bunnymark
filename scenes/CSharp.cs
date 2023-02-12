using Godot;
using System;
using System.Collections.Generic;

public partial class CSharp : Node2D
{
    float gravity = 500.0f;
    Texture2D bunny_texture = (Texture2D)ResourceLoader.Load("res://scenes/wabbit_alpha.png");
    List<Vector2> speeds = new List<Vector2>();
    Random random = new Random();
    Label label = new Label();
    Node2D bunnies = new Node2D();
    Vector2 screen_size = new Vector2();

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        this.AddChild(bunnies);
        label.Position = new Vector2(0, 20);
        this.AddChild(label);
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
        screen_size = GetViewportRect().Size;
        label.Text = "Bunnies: " + bunnies.GetChildCount();

        var bunnyChildren = bunnies.GetChildren();
        for (var i = 0; i < bunnyChildren.Count; i++)
        {
            var bunny = (Sprite2D)bunnyChildren[i];
            var position = bunny.Position;
            var speed = speeds[i];

            position.X += speed.X * (float)delta;
            position.Y += speed.Y * (float)delta;

            speed.Y += gravity * (float)delta;

            if (position.X > screen_size.X)
            {
                speed.X *= -1;
                position.X = screen_size.X;
            }

            if (position.X < 0)
            {
                speed.X *= -1;
                position.X = 0;
            }

            if (position.Y > screen_size.Y)
            {
                position.Y = screen_size.Y;
                if (random.NextDouble() > 0.5f)
                {
                    speed.Y = (random.Next() % 1100 + 50);
                }
                else
                {
                    speed.Y *= -0.85f;
                }
            }

            if (position.Y < 0)
            {
                speed.Y = 0;
                position.Y = 0;
            }

            bunny.Position = position;
            speeds[i] = speed;
        }
    }

    public void add_bunny()
    {
        var bunny = new Sprite2D();
        bunny.Texture = bunny_texture;
        bunnies.AddChild(bunny);
        bunny.Position = new Vector2(screen_size.X / 2, screen_size.Y / 2);
        speeds.Add(new Vector2(random.Next() % 200 + 50, random.Next() % 200 + 50));
    }

    public void remove_bunny()
    {
        var childCount = bunnies.GetChildCount();
        if (childCount == 0) {
            return;
        }

        var bunny = bunnies.GetChild(childCount - 1);
        speeds.RemoveAt(childCount - 1);
        bunnies.RemoveChild(bunny);
    }

    public void finish()
    {
        EmitSignal("benchmark_finished", bunnies.GetChildCount());
    }
}
