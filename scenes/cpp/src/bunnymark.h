#ifndef BUNNYMARK_CLASS_H
#define BUNNYMARK_CLASS_H

// We don't need windows.h in this example plugin but many others do, and it can
// lead to annoying situations due to the ton of macros it defines.
// So we include it and make sure CI warns us if we use something that conflicts
// with a Windows define.
#ifdef WIN32
#include <windows.h>
#endif


#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/classes/label.hpp>
#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/core/binder_common.hpp>

using namespace godot;

class CppBunnymarkV2 : public Node2D {
    GDCLASS(CppBunnymarkV2, Node2D);

    Vector2 screenSize;
    Ref<Texture2D> TBunny;
    float gravity = 500; 
    std::vector<Vector2> speeds;
    std::vector<Sprite2D*> bunnies;
    Label* label = new Label();
    Node2D* bunnyRoot = new Node2D();

protected:
    static void _bind_methods();

    void _notification(int p_what);
    bool _set(const StringName &p_name, const Variant &p_value);
    bool _get(const StringName &p_name, Variant &r_ret) const;
    void _get_property_list(List<PropertyInfo> *p_list) const;
    bool _property_can_revert(const StringName &p_name) const;
    bool _property_get_revert(const StringName &p_name, Variant &r_property) const;

    String _to_string() const;

public:
    CppBunnymarkV2();

    void _ready();
    
    void _process(double delta);
    void add_bunny();
    void remove_bunny();
    void finish();
};

#endif