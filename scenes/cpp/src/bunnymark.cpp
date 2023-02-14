#include "bunnymark.h"

#include <stdlib.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>


using namespace godot;

CppBunnymarkV2::CppBunnymarkV2() { 
	srand (time(NULL)); 
}

void CppBunnymarkV2::_ready() {
	TBunny = ResourceLoader::get_singleton()->load("res://scenes/wabbit_alpha.png");
	set_process(true);
    add_child(bunnyRoot);

    label->set_position(Vector2(0, 20));
    add_child(label);
}

void CppBunnymarkV2::_process(double delta) {
	screenSize = get_viewport_rect().size;

	for (int i = 0; i < bunnies.size(); i++) {
	    Sprite2D* bunny = bunnies[i];
	    Vector2 position = bunny->get_position();
	    Vector2 speed = speeds[i];

	    position.x += speed.x * delta;
	    position.y += speed.y * delta;

	    speed.y += gravity * delta;

	    if (position.x > screenSize.x)
	    {
	        speed.x *= -1;
	        position.x = screenSize.x;
	    }
	    if (position.x < 0)
	    {
	        speed.x *= -1;
	        position.x = 0;
	    }

	    if (position.y > screenSize.y)
	    {
	        position.y = screenSize.y;
	        if ((double)rand() / RAND_MAX > 0.5)
	        {
	            speed.y = (rand() % 1100 + 50);
	        }
	        else
	        {
	            speed.y *= -0.85f;
	        }
	    }

	    if (position.y < 0)
	    {
	        speed.y = 0;
	        position.y = 0;
	    }

	    bunny->set_position(position);
	    speeds[i] = speed;
	}
}

void CppBunnymarkV2::add_bunny() {
	Sprite2D* bunny = new Sprite2D();
    bunny->set_texture(TBunny.ptr());
    bunnies.push_back(bunny);
    bunnyRoot->add_child(bunny);
    bunny->set_position(Vector2(screenSize.x / 2.0, screenSize.y / 2.0));
    speeds.push_back(Vector2(rand()%200+50, rand()%200+50));

    String bunnies_count =  std::to_string(bunnies.size()).c_str();
	String label_value = "Bunnies: " + bunnies_count;
	label->set_text(label_value);
}

void CppBunnymarkV2::remove_bunny() {
	int child_count = bunnies.size();
	if (child_count == 0) {
	        return;
	}

	Sprite2D* bunny = bunnies[child_count - 1];
	bunnies.pop_back();
	speeds.pop_back();
	bunnyRoot->remove_child(bunny);

	String bunnies_count =  std::to_string(bunnies.size()).c_str();
	String label_value = "Bunnies: " + bunnies_count;
	label->set_text(label_value);
}
void CppBunnymarkV2::finish() {
    emit_signal("benchmark_finished", bunnies.size());
}

void CppBunnymarkV2::_notification(int p_what) {
	//UtilityFunctions::print("Notification: ", String::num(p_what));
}

bool CppBunnymarkV2::_set(const StringName &p_name, const Variant &p_value) {
	return false;
}

bool CppBunnymarkV2::_get(const StringName &p_name, Variant &r_ret) const {
	return false;
}

String CppBunnymarkV2::_to_string() const {
	return "[ GDExtension::CppBunnymarkV2 <--> Instance ID:" + uitos(get_instance_id()) + " ]";
}

void CppBunnymarkV2::_get_property_list(List<PropertyInfo> *p_list) const {
}

bool CppBunnymarkV2::_property_can_revert(const StringName &p_name) const {
	return false;
};

bool CppBunnymarkV2::_property_get_revert(const StringName &p_name, Variant &r_property) const {
	return false;
};

void CppBunnymarkV2::_bind_methods() {
	ClassDB::bind_method(D_METHOD("add_bunny"), &CppBunnymarkV2::add_bunny);
	ClassDB::bind_method(D_METHOD("remove_bunny"), &CppBunnymarkV2::remove_bunny);
	ClassDB::bind_method(D_METHOD("finish"), &CppBunnymarkV2::finish);
}