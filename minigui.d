// http://msdn.microsoft.com/en-us/library/windows/desktop/bb775498%28v=vs.85%29.aspx

/*

im tempted to add some css kind of thing to minigui. i've not done in the past cuz i have a lot of virtual functins i use but i think i have an evil plan

the virtual functions remain as the default calculated values. then the reads go through some proxy object that can override it...
*/

// FIXME: opt-in file picker widget with image support

// FIXME: number widget

// https://www.codeguru.com/cpp/controls/buttonctrl/advancedbuttons/article.php/c5161/Native-Win32-ThemeAware-OwnerDraw-Controls-No-MFC.htm
// https://docs.microsoft.com/en-us/windows/win32/controls/using-visual-styles

// osx style menu search.

// would be cool for a scroll bar to have marking capabilities
// kinda like vim's marks just on clicks etc and visual representation
// generically. may be cool to add an up arrow to the bottom too
//
// leave a shadow of where you last were for going back easily

// So a window needs to have a selection, and that can be represented by a type. This is manipulated by various
// functions like cut, copy, paste. Widgets can have a selection and that would assert teh selection ownership for
// the window.

// so what about context menus?

// https://docs.microsoft.com/en-us/windows/desktop/Controls/about-custom-draw

// FIXME: make the scroll thing go to bottom when the content changes.

// add a knob slider view... you click and go up and down so basically same as a vertical slider, just presented as a round image

// FIXME: the scroll area MUST be fixed to use the proper apis under the hood.


// FIXME: add a command search thingy built in and implement tip.
// FIXME: omg omg what if menu functions have arguments and it can pop up a gui or command line script them?!

// On Windows:
// FIXME: various labels look broken in high contrast mode
// FIXME: changing themes while the program is upen doesn't trigger a redraw

// add note about manifest to documentation. also icons.

// a pager control is just a horizontal scroll area just with arrows on the sides instead of a scroll bar
// FIXME: clear the corner of scrollbars if they pop up

// minigui needs to have a stdout redirection for gui mode on windows writeln

// I kinda wanna do state reacting. sort of. idk tho

// need a viewer widget that works like a web page - arrows scroll down consistently

// I want a nanovega widget, and a svg widget with some kind of event handlers attached to the inside.

// FIXME: the menus should be a bit more discoverable, at least a single click to open the others instead of two.
// and help info about menu items.
// and search in menus?

// FIXME: a scroll area event signaling when a thing comes into view might be good
// FIXME: arrow key navigation and accelerators in dialog boxes will be a must

// FIXME: unify Windows style line endings

/*
	TODO:

	pie menu

	class Form with submit behavior -- see AutomaticDialog

	disabled widgets and menu items

	event cleanup
	tooltips.
	api improvements

	margins are kinda broken, they don't collapse like they should. at least.

	a table form btw would be a horizontal layout of vertical layouts holding each column
	that would give the same width things
*/

/*

1(15:19:48) NotSpooky: Menus, text entry, label, notebook, box, frame, file dialogs and layout (this one is very useful because I can draw lines between its child widgets
*/

/++
	minigui is a smallish GUI widget library, aiming to be on par with at least
	HTML4 forms and a few other expected gui components. It uses native controls
	on Windows and does its own thing on Linux (Mac is not currently supported but
	may be later, and should use native controls) to keep size down. The Linux
	appearance is similar to Windows 95 and avoids using images to maintain network
	efficiency on remote X connections, though you can customize that.


	minigui's only required dependencies are [arsd.simpledisplay] and [arsd.color],
	on which it is built. simpledisplay provides the low-level interfaces and minigui
	builds the concept of widgets inside the windows on top of it.

	Its #1 goal is to be useful without being large and complicated like GTK and Qt.
	It isn't hugely concerned with appearance - on Windows, it just uses the native
	controls and native theme, and on Linux, it keeps it simple and I may change that
	at any time, though after May 2021, you can customize some things with css-inspired
	[Widget.Style] classes. (On Windows, if you compile with `-version=custom_widgets`,
	you can use the custom implementation there too, but... you shouldn't.)

	The event model is similar to what you use in the browser with Javascript and the
	layout engine tries to automatically fit things in, similar to a css flexbox.

	FOR BEST RESULTS: be sure to link with the appropriate subsystem command
	`-L/SUBSYSTEM:WINDOWS:5.0`, for example, because otherwise you'll get a
	console and other visual bugs.

	HTML_To_Classes:
	$(SMALL_TABLE
		HTML Code | Minigui Class

		`<input type="text">` | [LineEdit]
		`<textarea>` | [TextEdit]
		`<select>` | [DropDownSelection]
		`<input type="checkbox">` | [Checkbox]
		`<input type="radio">` | [Radiobox]
		`<button>` | [Button]
	)


	Stretchiness:
		The default is 4. You can use larger numbers for things that should
		consume a lot of space, and lower numbers for ones that are better at
		smaller sizes.

	Overlapped_input:
		COMING EVENTUALLY:
		minigui will include a little bit of I/O functionality that just works
		with the event loop. If you want to get fancy, I suggest spinning up
		another thread and posting events back and forth.

	$(H2 Add ons)
		See the `minigui_addons` directory in the arsd repo for some add on widgets
		you can import separately too.

	$(H3 XML definitions)
		If you use [arsd.minigui_xml], you can create widget trees from XML at runtime.

	$(H3 Scriptability)
		minigui is compatible with [arsd.script]. If you see `@scriptable` on a method
		in this documentation, it means you can call it from the script language.

		Tip: to allow easy creation of widget trees from script, import [arsd.minigui_xml]
		and make [arsd.minigui_xml.makeWidgetFromString] available to your script:

		---
		import arsd.minigui_xml;
		import arsd.script;

		var globals = var.emptyObject;
		globals.makeWidgetFromString = &makeWidgetFromString;

		// this now works
		interpret(`var window = makeWidgetFromString("<MainWindow />");`, globals);
		---

		More to come.

	History:
		Minigui had mostly additive changes or bug fixes since its inception until May 2021.

		In May 2021 (dub v10.0), minigui got an overhaul. If it was versioned independently, I'd
		tag this as version 2.0.

		Among the changes:
		$(LIST
			* The event model changed to prefer strongly-typed events, though the Javascript string style ones still work, using properties off them is deprecated. It will still compile and function, but you should change the handler to use the classes in its argument list. I adapted my code to use the new model in just a few minutes, so it shouldn't too hard.

			See [Event] for details.

			* A [DoubleClickEvent] was added. Previously, you'd get two rapidly repeated click events. Now, you get one click event followed by a double click event. If you must recreate the old way exactly, you can listen for a DoubleClickEvent, set a flag upon receiving one, then send yourself a synthetic ClickEvent on the next MouseUpEvent, but your program might be better served just working with [MouseDownEvent]s instead.

			See [DoubleClickEvent] for details.

			* Styling hints were added, and the few that existed before have been moved to a new helper class. Deprecated forwarders exist for the (few) old properties to help you transition. Note that most of these only affect a `custom_events` build, which is the default on Linux, but opt in only on Windows.

			See [Widget.Style] for details.

			// * A widget must now opt in to receiving keyboard focus, rather than opting out.

			* Widgets now draw their keyboard focus by default instead of opt in. You may wish to set `tabStop = false;` if it wasn't supposed to receive it.

			* Most Widget constructors no longer have a default `parent` argument. You must pass the parent to almost all widgets, or in rare cases, an explict `null`, but more often than not, you need the parent so the default argument was not very useful at best and misleading to a crash at worst.

			* [LabeledLineEdit] changed its default layout to vertical instead of horizontal. You can restore the old behavior by passing a `TextAlignment` argument to the constructor.

			* Several conversions of public fields to properties, deprecated, or made private. It is unlikely this will affect you, but the compiler will tell you if it does.

			* Various non-breaking additions.
		)
+/
module arsd.minigui;

/++
	This hello world sample will have an oversized button, but that's ok, you see your first window!
+/
version(Demo)
unittest {
	import arsd.minigui;

	void main() {
		auto window = new MainWindow();

		auto hello = new TextLabel("Hello, world!", TextAlignment.Center, window);
		auto button = new Button("Close", window);
		button.addEventListener((scope ClickEvent ev) {
			window.close();
		});

		window.loop();
	}

	main(); // exclude from docs
}

public import arsd.simpledisplay;
/++
	Convenience import to override the Windows GDI Rectangle function (you can still use it through fully-qualified imports)

	History:
		Was private until May 15, 2021.
+/
public alias Rectangle = arsd.color.Rectangle; // I specifically want this in here, not the win32 GDI Rectangle()

version(Windows) {
	import core.sys.windows.winnls;
	import core.sys.windows.windef;
	import core.sys.windows.basetyps;
	import core.sys.windows.winbase;
	import core.sys.windows.winuser;
	import core.sys.windows.wingdi;
	static import gdi = core.sys.windows.wingdi;
}

// this is a hack to call the original window procedure on native win32 widgets if our event listener thing prevents default.
private bool lastDefaultPrevented;

/// Methods marked with this are available from scripts if added to the [arsd.script] engine.
alias scriptable = arsd_jsvar_compatible;

version(Windows) {
	// use native widgets when available unless specifically asked otherwise
	version(custom_widgets) {
		enum bool UsingCustomWidgets = true;
		enum bool UsingWin32Widgets = false;
	} else {
		version = win32_widgets;
		enum bool UsingCustomWidgets = false;
		enum bool UsingWin32Widgets = true;
	}
	// and native theming when needed
	//version = win32_theming;
} else {
	enum bool UsingCustomWidgets = true;
	enum bool UsingWin32Widgets = false;
	version=custom_widgets;
}



/*

	The main goals of minigui.d are to:
		1) Provide basic widgets that just work in a lightweight lib.
		   I basically want things comparable to a plain HTML form,
		   plus the easy and obvious things you expect from Windows
		   apps like a menu.
		2) Use native things when possible for best functionality with
		   least library weight.
		3) Give building blocks to provide easy extension for your
		   custom widgets, or hooking into additional native widgets
		   I didn't wrap.
		4) Provide interfaces for easy interaction between third
		   party minigui extensions. (event model, perhaps
		   signals/slots, drop-in ease of use bits.)
		5) Zero non-system dependencies, including Phobos as much as
		   I reasonably can. It must only import arsd.color and
		   my simpledisplay.d. If you need more, it will have to be
		   an extension module.
		6) An easy layout system that generally works.

	A stretch goal is to make it easy to make gui forms with code,
	some kind of resource file (xml?) and even a wysiwyg designer.

	Another stretch goal is to make it easy to hook data into the gui,
	including from reflection. So like auto-generate a form from a
	function signature or struct definition, or show a list from an
	array that automatically updates as the array is changed. Then,
	your program focuses on the data more than the gui interaction.



	STILL NEEDED:
		* combo box. (this is diff than select because you can free-form edit too. more like a lineedit with autoselect)
		* slider
		* listbox
		* spinner
		* label?
		* rich text
*/


/+
	enum LayoutMethods {
		 verticalFlex,
		 horizontalFlex,
		 inlineBlock, // left to right, no stretch, goes to next line as needed
		 static, // just set to x, y
		 verticalNoStretch, // browser style default

		 inlineBlockFlex, // goes left to right, flexing, but when it runs out of space, it spills into next line

		 grid, // magic
	}
+/

/++
	The `Widget` is the base class for minigui's functionality, ranging from UI components like checkboxes or text displays to abstract groupings of other widgets like a layout container or a html `<div>`. You will likely want to use pre-made widgets as well as creating your own.


	To create your own widget, you must inherit from it and create a constructor that passes a parent to `super`. Everything else after that is optional.

	---
	class MinimalWidget : Widget {
		this(Widget parent) {
			super(parent);
		}
	}
	---

	$(SIDEBAR
		I'm not entirely happy with leaf, container, and windows all coming from the same base Widget class, but I so far haven't thought of a better solution that's good enough to justify the breakage of a transition. It hasn't been a major problem in practice anyway.
	)

	Broadly, there's two kinds of widgets: leaf widgets, which are intended to be the direct user-interactive components, and container widgets, which organize, lay out, and aggregate other widgets in the object tree. A special case of a container widget is [Window], which represents a separate top-level window on the screen. Both leaf and container widgets inherit from `Widget`, so this distinction is more conventional than formal.

	Among the things you'll most likely want to change in your custom widget:

	$(LIST
		* In your constructor, set `tabStop = false;` if the widget is not supposed to receive keyboard focus. (Please note its childen still can, so `tabStop = false;` is appropriate on most container widgets.)

		You may explicitly set `tabStop = true;` to ensure you get it, even against future changes to the library, though that's the default right now.

		Do this $(I after) calling the `super` constructor.

		* Override [paint] if you want full control of the widget's drawing area (except the area obscured by children!), or [paintContent] if you want to participate in the styling engine's system. You'll also possibly want to make a subclass of [Style] and use [OverrideStyle] to change the default hints given to the styling engine for widget.

		Generally, painting is a job for leaf widgets, since child widgets would obscure your drawing area anyway. However, it is your decision.

		* Override default event handlers with your behavior. For example [defaultEventHandler_click] may be overridden to make clicks do something. Again, this is generally a job for leaf widgets rather than containers; most events are dispatched to the lowest leaf on the widget tree, but they also pass through all their parents. See [Event] for more details about the event model.

		* You may also want to override the various layout hints like [minWidth], [maxHeight], etc. In particular [Padding] and [Margin] are often relevant for both container and leaf widgets and the default values of 0 are often not what you want.
	)

	On Microsoft Windows, many widgets are also based on native controls. You can also do this if `static if(UsingWin32Widgets)` passes. You should use the helper function [createWin32Window] to create the window and let minigui do what it needs to do to create its bridge structures. This will populate [Widget.hwnd] which you can access later for communcating with the native window. You may also consider overriding [Widget.handleWmCommand] and [Widget.handleWmNotify] for the widget to translate those messages into appropriate minigui [Event]s.

	It is also possible to embed a [SimpleWindow]-based native window inside a widget. See [OpenGlWidget]'s source code as an example.

	Your own custom-drawn and native system controls can exist side-by-side.

	Later I'll add more complete examples, but for now [TextLabel] and [LabeledPasswordEdit] are both simple widgets you can view implementation to get some ideas.
+/
class Widget : ReflectableProperties {


	/// Implementations of [ReflectableProperties] interface. See the interface for details.
	SetPropertyResult setPropertyFromString(string name, scope const(char)[] value, bool valueIsJson) {
		if(valueIsJson)
			return SetPropertyResult.wrongFormat;
		switch(name) {
			case "name":
				this.name = value.idup;
				return SetPropertyResult.success;
			case "statusTip":
				this.statusTip = value.idup;
				return SetPropertyResult.success;
			default:
				return SetPropertyResult.noSuchProperty;
		}
	}
	/// ditto
	void getPropertiesList(scope void delegate(string name) sink) const {
		sink("name");
		sink("statusTip");
	}
	/// ditto
	void getPropertyAsString(string name, scope void delegate(string name, scope const(char)[] value, bool valueIsJson) sink) {
		switch(name) {
			case "name":
				sink(name, this.name, false);
				return;
			case "statusTip":
				sink(name, this.statusTip, false);
				return;
			default:
				sink(name, null, true);
		}
	}

	/++
		If `encapsulatedChildren` returns true, it changes the event handling mechanism to act as if events from the child widgets are actually targeted on this widget.

		The idea is then you can use child widgets as part of your implementation, but not expose those details through the event system; if someone checks the mouse coordinates and target of the event once it bubbles past you, it will show as it it came from you.

		History:
			Added May 22, 2021
	+/
	protected bool encapsulatedChildren() {
		return false;
	}

	// Default layout properties {

		int minWidth() { return 0; }
		int minHeight() {
			// default widgets have a vertical layout, therefore the minimum height is the sum of the contents
			int sum = 0;
			foreach(child; children) {
				sum += child.minHeight();
				sum += child.marginTop();
				sum += child.marginBottom();
			}

			return sum;
		}
		int maxWidth() { return int.max; }
		int maxHeight() { return int.max; }
		int widthStretchiness() { return 4; }
		int heightStretchiness() { return 4; }

		int marginLeft() { return 0; }
		int marginRight() { return 0; }
		int marginTop() { return 0; }
		int marginBottom() { return 0; }
		int paddingLeft() { return 0; }
		int paddingRight() { return 0; }
		int paddingTop() { return 0; }
		int paddingBottom() { return 0; }
		//LinePreference linePreference() { return LinePreference.PreferOwnLine; }

		void recomputeChildLayout() {
			.recomputeChildLayout!"height"(this);
		}

	// }


	/++
		Returns the style's tag name string this object uses.

		The default is to use the typeid() name trimmed down to whatever is after the last dot which is typically the identifier of the class.

		This tag may never be used, it is just available for the [VisualTheme.getPropertyString] if it chooses to do something like CSS.

		History:
			Added May 10, 2021
	+/
	string styleTagName() const {
		string n = typeid(this).name;
		foreach_reverse(idx, ch; n)
			if(ch == '.') {
				n = n[idx + 1 .. $];
				break;
			}
		return n;
	}

	/// API for the [styleClassList]
	static struct ClassList {
		private Widget widget;

		///
		void add(string s) {
			widget.styleClassList_ ~= s;
		}

		///
		void remove(string s) {
			foreach(idx, s1; widget.styleClassList_)
				if(s1 == s) {
					widget.styleClassList_[idx] = widget.styleClassList_[$-1];
					widget.styleClassList_ = widget.styleClassList_[0 .. $-1];
					widget.styleClassList_.assumeSafeAppend();
					return;
				}
		}

		/// Returns true if it was added, false if it was removed.
		bool toggle(string s) {
			if(contains(s)) {
				remove(s);
				return false;
			} else {
				add(s);
				return true;
			}
		}

		///
		bool contains(string s) const {
			foreach(s1; widget.styleClassList_)
				if(s1 == s)
					return true;
			return false;

		}
	}

	private string[] styleClassList_;

	/++
		Returns a "class list" that can be used by the visual theme's style engine via [VisualTheme.getPropertyString] if it chooses to do something like CSS.

		It has no inherent meaning, it is really just a place to put some metadata tags on individual objects.

		History:
			Added May 10, 2021
	+/
	inout(ClassList) styleClassList() inout {
		return cast(inout(ClassList)) ClassList(cast() this);
	}

	/++
		List of dynamic states made available to the style engine, for cases like CSS pseudo-classes and also used by default paint methods. It is stored in a 64 bit variable attached to the widget that you can update. The style cache is aware of the fact that these can frequently change.

		The lower 32 bits are defined here or reserved for future use by the library. You should keep these updated if you reasonably can on custom widgets if they apply to you, but don't use them for a purpose they aren't defined for.

		The upper 32 bits are available for your own extensions.

		History:
			Added May 10, 2021
	+/
	enum DynamicState : ulong {
		focus = (1 << 0), /// the widget currently has the keyboard focus
		hover = (1 << 1), /// the mouse is currently hovering over the widget (may not always be updated)
		valid = (1 << 2), /// the widget's content has been validated and it passed (do not set if not validation has been performed!)
		invalid = (1 << 3), /// the widget's content has been validated and it failed (do not set if not validation has been performed!)
		checked = (1 << 4), /// the widget is toggleable and currently toggled on
		selected = (1 << 5), /// the widget represents one option of many and is currently selected, but is not necessarily focused nor checked.
		disabled = (1 << 6), /// the widget is currently unable to perform its designated task
		indeterminate = (1 << 7), /// the widget has tri-state and is between checked and not checked
		depressed = (1 << 8), /// the widget is being actively pressed or clicked (compare to css `:active`). Can be combined with hover to visually indicate if a mouse up would result in a click event.

		USER_BEGIN = (1UL << 32),
	}

	// I want to add the primary and cancel styles to buttons at least at some point somehow.

	/// ditto
	@property ulong dynamicState() { return dynamicState_; }
	/// ditto
	@property ulong dynamicState(ulong newValue) {
		if(dynamicState != newValue) {
			auto old = dynamicState_;
			dynamicState_ = newValue;

			useStyleProperties((scope Widget.Style s) {
				if(s.variesWithState(old ^ newValue))
					redraw();
			});
		}
		return dynamicState_;
	}

	/// ditto
	void setDynamicState(ulong flags, bool state) {
		auto ds = dynamicState_;
		if(state)
			ds |= flags;
		else
			ds &= ~flags;

		dynamicState = ds;
	}

	private ulong dynamicState_;

	deprecated("Use dynamic styles instead now") {
		Color backgroundColor() { return backgroundColor_; }
		void backgroundColor(Color c){ this.backgroundColor_ = c; }

		MouseCursor cursor() { return GenericCursor.Default; }
	} private Color backgroundColor_ = Color.transparent;


	/++
		Style properties are defined as an accessory class so they can be referenced and overridden independently.

		It is here so there can be a specificity switch.

		See [OverrideStyle] for a helper function to use your own.

		History:
			Added May 11, 2021
	+/
	static class Style/* : StyleProperties*/ {
		public Widget widget; // public because the mixin template needs access to it

		/// This assumes any change to the dynamic state (focus, hover, etc) triggers a redraw, but you can filter a bit to optimize some draws.
		bool variesWithState(ulong dynamicStateFlags) {
			return true;
		}

		///
		Color foregroundColor() {
			return WidgetPainter.visualTheme.foregroundColor;
		}

		///
		WidgetBackground background() {
			// the default is a "transparent" background, which means
			// it goes as far up as it can to get the color
			if (widget.backgroundColor_ != Color.transparent)
				return WidgetBackground(widget.backgroundColor_);
			if (widget.parent)
				return widget.parent.getComputedStyle.background;
			return WidgetBackground(widget.backgroundColor_);
		}

		private OperatingSystemFont fontCached_;
		private OperatingSystemFont fontCached() {
			if(fontCached_ is null)
				fontCached_ = font();
			return fontCached_;
		}

		/++
			Returns the default font to be used with this widget. The return value will be cached by the library, so you can not expect live updates.
		+/
		OperatingSystemFont font() {
			return null;
		}

		/++
			Returns the cursor that should be used over this widget. You may change this and updates will be reflected next time the mouse enters the widget.

			You can return a member of [GenericCursor] or your own [MouseCursor] instance.

			History:
				Was previously a method directly on [Widget], moved to [Widget.Style] on May 12, 2021
		+/
		MouseCursor cursor() {
			return GenericCursor.Default;
		}

		FrameStyle borderStyle() {
			return FrameStyle.none;
		}

		/++
		+/
		Color borderColor() {
			return Color.transparent;
		}

		FrameStyle outlineStyle() {
			if(widget.dynamicState & DynamicState.focus)
				return FrameStyle.dotted;
			else
				return FrameStyle.none;
		}

		Color outlineColor() {
			return foregroundColor;
		}
	}

	/++
		This mixin overrides the [useStyleProperties] method to direct it toward your own style class.
		The basic usage is simple:

		---
		static class Style : YourParentClass.Style { /* YourParentClass is frequently Widget, of course, but not always */
			// override style hints as-needed here
		}
		OverrideStyle!Style; // add the method
		---

		$(TIP
			While the class is not forced to be `static`, for best results, it should be. A non-static class
			can not be inherited by other objects whereas the static one can. A property on the base class,
			called [Widget.Style.widget|widget], is available for you to access its properties.
		)

		This exists just because [useStyleProperties] has a somewhat convoluted signature and its overrides must
		repeat them. Moreover, its implementation uses a stack class to optimize GC pressure from small fetches
		and that's a little tedious to repeat in your child classes too when you only care about changing the type.


		It also has a further facility to pick a wholly differnet class based on the [DynamicState] of the Widget.

		---
		mixin OverrideStyle!(
			DynamicState.focus, YourFocusedStyle,
			DynamicState.hover, YourHoverStyle,
			YourDefaultStyle
		)
		---

		It checks if `dynamicState` matches the state and if so, returns the object given.

		If there is no state mask given, the next one matches everything. The first match given is used.

		However, since in most cases you'll want check state inside your individual methods, you probably won't
		find much use for this whole-class swap out.

		History:
			Added May 16, 2021
	+/
	static protected mixin template OverrideStyle(S...) {
		override void useStyleProperties(scope void delegate(scope Widget.Style props) dg) {
			ulong mask = 0;
			foreach(idx, thing; S) {
				static if(is(typeof(thing) : ulong)) {
					mask = thing;
				} else {
					if(!(idx & 1) || (this.dynamicState & mask) == mask) {
						//static assert(!__traits(isNested, thing), thing.stringof ~ " is a nested class. For best results, mark it `static`. You can still access the widget through a `widget` variable inside the Style class.");
						scope Widget.Style s = new thing();
						s.widget = this;
						dg(s);
						return;
					}
				}
			}
		}
	}
	/++
		You can override this by hand, or use the [OverrideStyle] helper which is a bit less verbose.
	+/
	void useStyleProperties(scope void delegate(scope Style props) dg) {
		scope Style s = new Style();
		s.widget = this;
		dg(s);
	}


	protected void sendResizeEvent() {
		this.emit!ResizeEvent();
	}

	Menu contextMenu(int x, int y) { return null; }

	final bool showContextMenu(int x, int y, int screenX = -2, int screenY = -2) {
		if(parentWindow is null || parentWindow.win is null) return false;

		auto menu = this.contextMenu(x, y);
		if(menu is null)
			return false;

		version(win32_widgets) {
			// FIXME: if it is -1, -1, do it at the current selection location instead
			// tho the corner of the window, whcih it does now, isn't the literal worst.

			if(screenX < 0 && screenY < 0) {
				auto p = this.globalCoordinates();
				if(screenX == -2)
					p.x += x;
				if(screenY == -2)
					p.y += y;

				screenX = p.x;
				screenY = p.y;
			}

			if(!TrackPopupMenuEx(menu.handle, 0, screenX, screenY, parentWindow.win.impl.hwnd, null))
				throw new Exception("TrackContextMenuEx");
		} else version(custom_widgets) {
			menu.popup(this, x, y);
		}

		return true;
	}

	/++
		Removes this widget from its parent.

		History:
			`removeWidget` was made `final` on May 11, 2021.
	+/
	@scriptable
	final void removeWidget() {
		auto p = this.parent;
		if(p) {
			int item;
			for(item = 0; item < p._children.length; item++)
				if(p._children[item] is this)
					break;
			for(; item < p._children.length - 1; item++)
				p._children[item] = p._children[item + 1];
			p._children = p._children[0 .. $-1];
		}
	}

	/++
		Calls [getByName] with the generic type of Widget. Meant for script interop where instantiating a template is impossible.
	+/
	@scriptable
	Widget getChildByName(string name) {
		return getByName(name);
	}
	/++
		Finds the nearest descendant with the requested type and [name]. May return `this`.
	+/
	final WidgetClass getByName(WidgetClass = Widget)(string name) {
		if(this.name == name)
			if(auto c = cast(WidgetClass) this)
				return c;
		foreach(child; children) {
			auto w = child.getByName(name);
			if(auto c = cast(WidgetClass) w)
				return c;
		}
		return null;
	}

	/++
		The name is a string tag that is used to reference the widget from scripts, gui loaders, declarative ui templates, etc. Similar to a HTML id attribute.
		Names should be unique in a window.

		See_Also: [getByName], [getChildByName]
	+/
	@scriptable string name;

	private EventHandler[][string] bubblingEventHandlers;
	private EventHandler[][string] capturingEventHandlers;

	/++
		Default event handlers. These are called on the appropriate
		event unless [Event.preventDefault] is called on the event at
		some point through the bubbling process.


		If you are implementing your own widget and want to add custom
		events, you should follow the same pattern here: create a virtual
		function named `defaultEventHandler_eventname` with the implementation,
		then, override [setupDefaultEventHandlers] and add a wrapped caller to
		`defaultEventHandlers["eventname"]`. It should be wrapped like so:
		`defaultEventHandlers["eventname"] = (Widget t, Event event) { t.defaultEventHandler_name(event); };`.
		This ensures virtual dispatch based on the correct subclass.

		Also, don't forget to call `super.setupDefaultEventHandlers();` too in your
		overridden version.

		You only need to do that on parent classes adding NEW event types. If you
		just want to change the default behavior of an existing event type in a subclass,
		you override the function (and optionally call `super.method_name`) like normal.

	+/
	protected EventHandler[string] defaultEventHandlers;

	/// ditto
	void setupDefaultEventHandlers() {
		defaultEventHandlers["click"] = (Widget t, Event event) { t.defaultEventHandler_click(cast(ClickEvent) event); };
		defaultEventHandlers["keydown"] = (Widget t, Event event) { t.defaultEventHandler_keydown(cast(KeyDownEvent) event); };
		defaultEventHandlers["keyup"] = (Widget t, Event event) { t.defaultEventHandler_keyup(cast(KeyUpEvent) event); };
		defaultEventHandlers["mouseover"] = (Widget t, Event event) { t.defaultEventHandler_mouseover(cast(MouseOverEvent) event); };
		defaultEventHandlers["mouseout"] = (Widget t, Event event) { t.defaultEventHandler_mouseout(cast(MouseOutEvent) event); };
		defaultEventHandlers["mousedown"] = (Widget t, Event event) { t.defaultEventHandler_mousedown(cast(MouseDownEvent) event); };
		defaultEventHandlers["mouseup"] = (Widget t, Event event) { t.defaultEventHandler_mouseup(cast(MouseUpEvent) event); };
		defaultEventHandlers["mouseenter"] = (Widget t, Event event) { t.defaultEventHandler_mouseenter(cast(MouseEnterEvent) event); };
		defaultEventHandlers["mouseleave"] = (Widget t, Event event) { t.defaultEventHandler_mouseleave(cast(MouseLeaveEvent) event); };
		defaultEventHandlers["mousemove"] = (Widget t, Event event) { t.defaultEventHandler_mousemove(cast(MouseMoveEvent) event); };
		defaultEventHandlers["char"] = (Widget t, Event event) { t.defaultEventHandler_char(cast(CharEvent) event); };
		defaultEventHandlers["triggered"] = (Widget t, Event event) { t.defaultEventHandler_triggered(event); };
		defaultEventHandlers["change"] = (Widget t, Event event) { t.defaultEventHandler_change(event); };
		defaultEventHandlers["focus"] = (Widget t, Event event) { t.defaultEventHandler_focus(event); };
		defaultEventHandlers["blur"] = (Widget t, Event event) { t.defaultEventHandler_blur(event); };
	}

	/// ditto
	void defaultEventHandler_click(ClickEvent event) {}
	/// ditto
	void defaultEventHandler_keydown(KeyDownEvent event) {}
	/// ditto
	void defaultEventHandler_keyup(KeyUpEvent event) {}
	/// ditto
	void defaultEventHandler_mousedown(MouseDownEvent event) {
		if(this.tabStop)
			this.focus();
	}
	/// ditto
	void defaultEventHandler_mouseover(MouseOverEvent event) {}
	/// ditto
	void defaultEventHandler_mouseout(MouseOutEvent event) {}
	/// ditto
	void defaultEventHandler_mouseup(MouseUpEvent event) {}
	/// ditto
	void defaultEventHandler_mousemove(MouseMoveEvent event) {}
	/// ditto
	void defaultEventHandler_mouseenter(MouseEnterEvent event) {}
	/// ditto
	void defaultEventHandler_mouseleave(MouseLeaveEvent event) {}
	/// ditto
	void defaultEventHandler_char(CharEvent event) {}
	/// ditto
	void defaultEventHandler_triggered(Event event) {}
	/// ditto
	void defaultEventHandler_change(Event event) {}
	/// ditto
	void defaultEventHandler_focus(Event event) {}
	/// ditto
	void defaultEventHandler_blur(Event event) {}

	/++
		[Event]s use a Javascript-esque model. See more details on the [Event] page.

		[addEventListener] returns an opaque handle that you can later pass to [removeEventListener].

		addDirectEventListener just inserts a check `if(e.target !is this) return;` meaning it opts out
		of participating in handler delegation.

		$(TIP
			Use `scope` on your handlers when you can. While it currently does nothing, this will future-proof your code against future optimizations I want to do. Instead of copying whole event objects out if you do need to store them, just copy the properties you need.
		)
	+/
	EventListener addDirectEventListener(string event, void delegate() handler, bool useCapture = false) {
		return addEventListener(event, (Widget, scope Event e) {
			if(e.srcElement is this)
				handler();
		}, useCapture);
	}

	/// ditto
	EventListener addDirectEventListener(string event, void delegate(Event) handler, bool useCapture = false) {
		return addEventListener(event, (Widget, Event e) {
			if(e.srcElement is this)
				handler(e);
		}, useCapture);
	}

	/// ditto
	@scriptable
	EventListener addEventListener(string event, void delegate() handler, bool useCapture = false) {
		return addEventListener(event, (Widget, scope Event) { handler(); }, useCapture);
	}

	/// ditto
	EventListener addEventListener(Handler)(Handler handler, bool useCapture = false) {
		static if(is(Handler Fn == delegate)) {
		static if(is(Fn Params == __parameters)) {
			return addEventListener(EventString!(Params[0]), (Widget, Event e) {
				auto ty = cast(Params[0]) e;
				if(ty !is null)
					handler(ty);
			}, useCapture);
		} else static assert(0);
		} else static assert(0, "Your handler wasn't usable because it wasn't passed a delegate.");
	}

	/// ditto
	EventListener addEventListener(string event, void delegate(Event) handler, bool useCapture = false) {
		return addEventListener(event, (Widget, Event e) { handler(e); }, useCapture);
	}

	/// ditto
	EventListener addEventListener(string event, EventHandler handler, bool useCapture = false) {
		if(event.length > 2 && event[0..2] == "on")
			event = event[2 .. $];

		if(useCapture)
			capturingEventHandlers[event] ~= handler;
		else
			bubblingEventHandlers[event] ~= handler;

		return EventListener(this, event, handler, useCapture);
	}

	/// ditto
	void removeEventListener(string event, EventHandler handler, bool useCapture = false) {
		if(event.length > 2 && event[0..2] == "on")
			event = event[2 .. $];

		if(useCapture) {
			if(event in capturingEventHandlers)
			foreach(ref evt; capturingEventHandlers[event])
				if(evt is handler) evt = null;
		} else {
			if(event in bubblingEventHandlers)
			foreach(ref evt; bubblingEventHandlers[event])
				if(evt is handler) evt = null;
		}
	}

	/// ditto
	void removeEventListener(EventListener listener) {
		removeEventListener(listener.event, listener.handler, listener.useCapture);
	}

	static if(UsingSimpledisplayX11) {
		void discardXConnectionState() {
			foreach(child; children)
				child.discardXConnectionState();
		}

		void recreateXConnectionState() {
			foreach(child; children)
				child.recreateXConnectionState();
			redraw();
		}
	}

	/++
		Returns the coordinates of this widget on the screen, relative to the upper left corner of the whole screen.

		History:
			`globalCoordinates` was made `final` on May 11, 2021.
	+/
	Point globalCoordinates() {
		int x = this.x;
		int y = this.y;
		auto p = this.parent;
		while(p) {
			x += p.x;
			y += p.y;
			p = p.parent;
		}

		static if(UsingSimpledisplayX11) {
			auto dpy = XDisplayConnection.get;
			arsd.simpledisplay.Window dummyw;
			XTranslateCoordinates(dpy, this.parentWindow.win.impl.window, RootWindow(dpy, DefaultScreen(dpy)), x, y, &x, &y, &dummyw);
		} else {
			POINT pt;
			pt.x = x;
			pt.y = y;
			MapWindowPoints(this.parentWindow.win.impl.hwnd, null, &pt, 1);
			x = pt.x;
			y = pt.y;
		}

		return Point(x, y);
	}

	version(win32_widgets)
	/// Called when a WM_COMMAND is sent to the associated hwnd.
	void handleWmCommand(ushort cmd, ushort id) {}

	version(win32_widgets)
	/// Called when a WM_NOTIFY is sent to the associated hwnd.
	int handleWmNotify(NMHDR* hdr, int code) { return 0; }

	/++
		This tip is displayed in the status bar (if there is one in the containing window) when the mouse moves over this widget.

		Updates to this variable will only be made visible on the next mouse enter event.
	+/
	@scriptable string statusTip;
	// string toolTip;
	// string helpText;

	/++
		If true, this widget can be focused via keyboard control with the tab key.

		If false, it is assumed the widget itself does will never receive the keyboard focus (though its childen are free to).
	+/
	bool tabStop = true;
	/++
		The tab key cycles through widgets by the order of a.tabOrder < b.tabOrder. If they are equal, it does them in child order (which is typically the order they were added to the widget.)
	+/
	int tabOrder;

	version(win32_widgets) {
		static Widget[HWND] nativeMapping;
		/// The native handle, if there is one.
		HWND hwnd;
		WNDPROC originalWindowProcedure;

		SimpleWindow simpleWindowWrappingHwnd;

		int hookedWndProc(UINT iMessage, WPARAM wParam, LPARAM lParam) {
			switch(iMessage) {
				case WM_COMMAND:
					auto handle = cast(HWND) lParam;
					auto cmd = HIWORD(wParam);
					return processWmCommand(hwnd, handle, cmd, LOWORD(wParam));
				default:
			}
			return 0;
		}
	}
	private bool implicitlyCreated;

	/// Child's position relative to the parent's origin. only the layout manager should be modifying this and even reading it is of limited utility. It may be made `private` at some point in the future without advance notice. Do NOT depend on it being available unless you are writing a layout manager.
	int x;
	/// ditto
	int y;
	private int _width;
	private int _height;
	private Widget[] _children;
	private Widget _parent;
	private Window _parentWindow;

	/++
		Returns the window to which this widget is attached.

		History:
			Prior to May 11, 2021, the `Window parentWindow` variable was directly available. Now, only this property getter is available and the actual store is private.
	+/
	final @property inout(Window) parentWindow() inout @nogc nothrow pure { return _parentWindow; }
	private @property void parentWindow(Window parent) {
		_parentWindow = parent;
		foreach(child; children)
			child.parentWindow = parent; // please note that this is recursive
	}

	/++
		Returns the list of the widget's children.

		History:
			Prior to May 11, 2021, the `Widget[] children` was directly available. Now, only this property getter is available and the actual store is private.

			Children should be added by the constructor most the time, but if that's impossible, use [addChild] and [removeWidget] to manage the list.
	+/
	final @property inout(Widget)[] children() inout @nogc nothrow pure { return _children; }

	/++
		Returns the widget's parent.

		History:
			Prior to May 11, 2021, the `Widget parent` variable was directly available. Now, only this property getter is permitted.

			The parent should only be managed by the [addChild] and [removeWidget] method.
	+/
	final @property inout(Widget) parent() inout nothrow @nogc pure @safe return { return _parent; }

	/// The widget's current size.
	final @scriptable public @property int width() const nothrow @nogc pure @safe { return _width; }
	/// ditto
	final @scriptable public @property int height() const nothrow @nogc pure @safe { return _height; }

	/// Only the layout manager should be calling these.
	final protected @property int width(int a) @safe { return _width = a; }
	/// ditto
	final protected @property int height(int a) @safe { return _height = a; }

	/++
		This function is called by the layout engine after it has updated the position (in variables `x` and `y`) and the size (in properties `width` and `height`) to give you a chance to update the actual position of the native child window (if there is one) or whatever.

		It is also responsible for calling [sendResizeEvent] to notify other listeners that the widget has changed size.
	+/
	protected void registerMovement() {
		version(win32_widgets) {
			if(hwnd) {
				auto pos = getChildPositionRelativeToParentHwnd(this);
				MoveWindow(hwnd, pos[0], pos[1], width, height, true);
			}
		}
		sendResizeEvent();
	}

	/// Creates the widget and adds it to the parent.
	this(Widget parent) {
		if(parent !is null)
			parent.addChild(this);
		setupDefaultEventHandlers();
	}

	/// Returns true if this is the current focused widget inside the parent window. Please note it may return `true` when the window itself is unfocused. In that case, it indicates this widget will receive focuse again when the window does.
	@scriptable
	bool isFocused() {
		return parentWindow && parentWindow.focusedWidget is this;
	}

	private bool showing_ = true;
	///
	bool showing() { return showing_; }
	///
	bool hidden() { return !showing_; }
	/++
		Shows or hides the window. Meant to be assigned as a property. If `recalculate` is true (the default), it recalculates the layout of the parent widget to use the space this widget being hidden frees up or make space for this widget to appear again.
	+/
	void showing(bool s, bool recalculate = true) {
		auto so = showing_;
		showing_ = s;
		if(s != so) {

			version(win32_widgets)
			if(hwnd)
				ShowWindow(hwnd, s ? SW_SHOW : SW_HIDE);

			if(parent && recalculate) {
				parent.recomputeChildLayout();
				parent.redraw();
			}

			foreach(child; children)
				child.showing(s, false);
		}
	}
	/// Convenience method for `showing = true`
	@scriptable
	void show() {
		showing = true;
	}
	/// Convenience method for `showing = false`
	@scriptable
	void hide() {
		showing = false;
	}

	///
	@scriptable
	void focus() {
		assert(parentWindow !is null);
		if(isFocused())
			return;

		if(parentWindow.focusedWidget) {
			// FIXME: more details here? like from and to
			auto from = parentWindow.focusedWidget;
			parentWindow.focusedWidget.setDynamicState(DynamicState.focus, false);
			parentWindow.focusedWidget = null;
			from.emit!BlurEvent();
		}


		version(win32_widgets) {
			if(this.hwnd !is null)
				SetFocus(this.hwnd);
		}

		parentWindow.focusedWidget = this;
		parentWindow.focusedWidget.setDynamicState(DynamicState.focus, true);
		this.emit!FocusEvent();
	}


	/++
		This is called when the widget is added to a window. It gives you a chance to set up event hooks.

		Update on May 11, 2021: I'm considering removing this method. You can usually achieve these things through looser-coupled methods.
	+/
	void attachedToWindow(Window w) {}
	/++
		Callback when the widget is added to another widget.

		Update on May 11, 2021: I'm considering removing this method since I've never actually found it useful.
	+/
	void addedTo(Widget w) {}

	/++
		Adds a child to the given position. This is `protected` because you generally shouldn't be calling this directly. Instead, construct widgets with the parent directly.

		This is available primarily to be overridden. For example, [MainWindow] overrides it to redirect its children into a central widget.
	+/
	protected void addChild(Widget w, int position = int.max) {
		w._parent = this;
		if(position == int.max || position == children.length) {
			_children ~= w;
		} else {
			assert(position < _children.length);
			_children.length = _children.length + 1;
			for(int i = cast(int) _children.length - 1; i > position; i--)
				_children[i] = _children[i - 1];
			_children[position] = w;
		}

		this.parentWindow = this._parentWindow;

		w.addedTo(this);

		if(this.hidden)
			w.showing = false;

		if(parentWindow !is null) {
			w.attachedToWindow(parentWindow);
			parentWindow.recomputeChildLayout();
			parentWindow.redraw();
		}
	}

	/++
		Finds the child at the top of the z-order at the given coordinates (relative to the `this` widget's origin), or null if none are found.
	+/
	Widget getChildAtPosition(int x, int y) {
		// it goes backward so the last one to show gets picked first
		// might use z-index later
		foreach_reverse(child; children) {
			if(child.hidden)
				continue;
			if(child.x <= x && child.y <= y
				&& ((x - child.x) < child.width)
				&& ((y - child.y) < child.height))
			{
				return child;
			}
		}

		return null;
	}

	/++
		Responsible for actually painting the widget to the screen. The clip rectangle and coordinate translation in the [WidgetPainter] are pre-configured so you can draw independently.

		This function paints the entire widget, including styled borders, backgrounds, etc. You are also responsible for displaying any important active state to the user, including if you hold the active keyboard focus. If you only want to be responsible for the content while letting the style engine draw the rest, override [paintContent] instead.

		[paint] is not called for system widgets as the OS library draws them instead.


		The default implementation forwards to [WidgetPainter.drawThemed], passing [paintContent] as the delegate. If you override this, you might use those same functions or you can do your own thing.

		You should also look at [WidgetPainter.visualTheme] to be theme aware.

		History:
			Prior to May 15, 2021, the default implementation was empty. Now, it is `painter.drawThemed(&paintContent);`. You may wish to override [paintContent] instead of [paint] to take advantage of the new styling engine.
	+/
	void paint(WidgetPainter painter) {
		painter.drawThemed(&paintContent); // note this refers to the following overload
	}

	/++
		Responsible for drawing the content as the theme engine is responsible for other elements.

		$(WARNING If you override [paint], this method may never be used as it is only called from inside the default implementation of `paint`.)

		Params:
			painter = your painter (forwarded from [paint]) for drawing on the widget. The clip rectangle and coordinate translation are prepared for you ahead of time so you can use widget coordinates. It also has the theme foreground preloaded into the painter outline color, the theme font preloaded as the painter's active font, and the theme background preloaded as the painter's fill color.

			bounds = the bounds, inside the widget, where your content should be drawn. This is the rectangle inside the border and padding (if any). The stuff outside is not clipped - it is still part of your widget - but you should respect these bounds for visual consistency and respecting the theme's area.

			If you do want to clip it, you can of course call `auto oldClip = painter.setClipRectangle(bounds); scope(exit) painter.setClipRectangle(oldClip);` to modify it and return to the previous setting when you return.

		Returns:
			The rectangle representing your actual content. Typically, this is simply `return bounds;`. The theme engine uses this return value to determine where the outline and overlay should be.

		History:
			Added May 15, 2021
	+/
	Rectangle paintContent(WidgetPainter painter, const Rectangle bounds) {
		return bounds;
	}

	deprecated("Change ScreenPainter to WidgetPainter")
	final void paint(ScreenPainter) { assert(0, "Change ScreenPainter to WidgetPainter and recompile your code"); }

	/// I don't actually like the name of this
	/// this draws a background on it
	void erase(WidgetPainter painter) {
		version(win32_widgets)
			if(hwnd) return; // Windows will do it. I think.

		auto c = getComputedStyle().background.color;
		painter.fillColor = c;
		painter.outlineColor = c;

		version(win32_widgets) {
			HANDLE b, p;
			if(c.a == 0) {
				b = SelectObject(painter.impl.hdc, GetSysColorBrush(COLOR_3DFACE));
				p = SelectObject(painter.impl.hdc, GetStockObject(NULL_PEN));
			}
		}
		painter.drawRectangle(Point(0, 0), width, height);
		version(win32_widgets) {
			if(c.a == 0) {
				SelectObject(painter.impl.hdc, p);
				SelectObject(painter.impl.hdc, b);
			}
		}
	}

	///
	WidgetPainter draw() {
		int x = this.x, y = this.y;
		auto parent = this.parent;
		while(parent) {
			x += parent.x;
			y += parent.y;
			parent = parent.parent;
		}

		auto painter = parentWindow.win.draw();
		painter.originX = x;
		painter.originY = y;
		painter.setClipRectangle(Point(0, 0), width, height);
		return WidgetPainter(painter, this);
	}

	/// This can be overridden by scroll things. It is responsible for actually calling [paint]. Do not override unless you've studied minigui.d's source code.
	protected void privatePaint(WidgetPainter painter, int lox, int loy, bool force = false) {
		if(hidden)
			return;

		painter.originX = lox + x;
		painter.originY = loy + y;

		bool actuallyPainted = false;

		if(redrawRequested || force) {
			painter.setClipRectangle(Point(0, 0), width, height);

			painter.drawingUpon = this;

			erase(painter);
			if(painter.visualTheme)
				painter.visualTheme.doPaint(this, painter);
			else
				paint(painter);

			redrawRequested = false;
			actuallyPainted = true;
		}

		foreach(child; children) {
			version(win32_widgets)
				if(child.useNativeDrawing()) continue;
			child.privatePaint(painter, painter.originX, painter.originY, actuallyPainted);
		}

		version(win32_widgets)
		foreach(child; children) {
			if(child.useNativeDrawing) {
				painter = WidgetPainter(child.simpleWindowWrappingHwnd.draw, child);
				child.privatePaint(painter, painter.originX, painter.originY, actuallyPainted);
			}
		}
	}

	protected bool useNativeDrawing() nothrow {
		version(win32_widgets)
			return hwnd !is null;
		else
			return false;
	}

	private static class RedrawEvent {}
	private __gshared re = new RedrawEvent();

	private bool redrawRequested;
	///
	final void redraw(string file = __FILE__, size_t line = __LINE__) {
		redrawRequested = true;

		if(this.parentWindow) {
			auto sw = this.parentWindow.win;
			assert(sw !is null);
			if(!sw.eventQueued!RedrawEvent) {
				sw.postEvent(re);
				//import std.stdio; writeln("redraw requested from ", file,":",line," ", this.parentWindow.win.impl.window);
			}
		}
	}

	private void actualRedraw() {
		if(!showing) return;

		assert(parentWindow !is null);

		auto w = drawableWindow;
		if(w is null)
			w = parentWindow.win;

		if(w.closed())
			return;

		auto ugh = this.parent;
		int lox, loy;
		while(ugh) {
			lox += ugh.x;
			loy += ugh.y;
			ugh = ugh.parent;
		}
		auto painter = w.draw();
		privatePaint(WidgetPainter(painter, this), lox, loy);
	}

	private SimpleWindow drawableWindow;

	/++
		Allows a class to easily dispatch its own statically-declared event (see [Emits]). The main benefit of using this over constructing an event yourself is simply that you ensure you haven't sent something you haven't documented you can send.

		Returns:
			`true` if you should do your default behavior.

		History:
			Added May 5, 2021

		Bugs:
			It does not do the static checks on gdc right now.
	+/
	final protected bool emit(EventType, this This, Args...)(Args args) {
		version(GNU) {} else
		static assert(classStaticallyEmits!(This, EventType), "The " ~ This.stringof ~ " class is not declared to emit " ~ EventType.stringof);
		auto e = new EventType(this, args);
		e.dispatch();
		return !e.defaultPrevented;
	}
	/// ditto
	final protected bool emit(string eventString, this This)() {
		auto e = new Event(eventString, this);
		e.dispatch();
		return !e.defaultPrevented;
	}

	/++
		Does the same as [addEventListener]'s delegate overload, but adds an additional check to ensure the event you are subscribing to is actually emitted by the static type you are using. Since it works on static types, if you have a generic [Widget], this can only subscribe to events declared as [Emits] inside [Widget] itself, not any child classes nor any child elements. If this is too restrictive, simply use [addEventListener] instead.

		History:
			Added May 5, 2021
	+/
	final public EventListener subscribe(EventType, this This)(void delegate(EventType) handler) {
		static assert(classStaticallyEmits!(This, EventType), "The " ~ This.stringof ~ " class is not declared to emit " ~ EventType.stringof);
		return addEventListener(handler);
	}

	/++
		Gets the computed style properties from the visual theme.

		You should use this in your paint and layout functions instead of the direct properties on the widget if you want to be style aware. (But when setting defaults in your classes, overriding is the right thing to do. Override to set defaults, but then read out of [getComputedStyle].)

		History:
			Added May 8, 2021
	+/
	final StyleInformation getComputedStyle() {
		return StyleInformation(this);
	}

	// FIXME: I kinda want to hide events from implementation widgets
	// so it just catches them all and stops propagation...
	// i guess i can do it with a event listener on star.

	mixin Emits!KeyDownEvent; ///
	mixin Emits!KeyUpEvent; ///
	mixin Emits!CharEvent; ///

	mixin Emits!MouseDownEvent; ///
	mixin Emits!MouseUpEvent; ///
	mixin Emits!ClickEvent; ///
	mixin Emits!DoubleClickEvent; ///
	mixin Emits!MouseMoveEvent; ///
	mixin Emits!MouseOverEvent; ///
	mixin Emits!MouseOutEvent; ///
	mixin Emits!MouseEnterEvent; ///
	mixin Emits!MouseLeaveEvent; ///

	mixin Emits!ResizeEvent; ///

	mixin Emits!BlurEvent; ///
	mixin Emits!FocusEvent; ///
}

///
abstract class ComboboxBase : Widget {
	// if the user can enter arbitrary data, we want to use  2 == CBS_DROPDOWN
	// or to always show the list, we want CBS_SIMPLE == 1
	version(win32_widgets)
		this(uint style, Widget parent) {
			super(parent);
			createWin32Window(this, "ComboBox"w, null, style);
		}
	else version(custom_widgets)
		this(Widget parent) {
			super(parent);

			addEventListener((KeyDownEvent event) {
				if(event.key == Key.Up) {
					if(selection > -1) { // -1 means select blank
						selection--;
						fireChangeEvent();
					}
					event.preventDefault();
				}
				if(event.key == Key.Down) {
					if(selection + 1 < options.length) {
						selection++;
						fireChangeEvent();
					}
					event.preventDefault();
				}

			});

		}
	else static assert(false);

	private string[] options;
	private int selection = -1;

	void addOption(string s) {
		options ~= s;
		version(win32_widgets)
		SendMessageW(hwnd, 323 /*CB_ADDSTRING*/, 0, cast(LPARAM) toWstringzInternal(s));
	}

	void setSelection(int idx) {
		selection = idx;
		version(win32_widgets)
		SendMessageW(hwnd, 334 /*CB_SETCURSEL*/, idx, 0);

		auto t = new SelectionChangedEvent(this, selection, selection == -1 ? null : options[selection]);
		t.dispatch();
	}

	static class SelectionChangedEvent : Event {
		this(Widget target, int iv, string sv) {
			super("change", target);
			this.iv = iv;
			this.sv = sv;
		}
		immutable int iv;
		immutable string sv;

		override @property string stringValue() { return sv; }
		override @property int intValue() { return iv; }
	}

	version(win32_widgets)
	override void handleWmCommand(ushort cmd, ushort id) {
		selection = cast(int) SendMessageW(hwnd, 327 /* CB_GETCURSEL */, 0, 0);
		fireChangeEvent();
	}

	private void fireChangeEvent() {
		if(selection >= options.length)
			selection = -1;

		auto t = new SelectionChangedEvent(this, selection, selection == -1 ? null : options[selection]);
		t.dispatch();
	}

	version(win32_widgets) {
		override int minHeight() { return Window.lineHeight + 6; }
		override int maxHeight() { return Window.lineHeight + 6; }
	} else {
		override int minHeight() { return Window.lineHeight + 4; }
		override int maxHeight() { return Window.lineHeight + 4; }
	}

	version(custom_widgets) {
		SimpleWindow dropDown;
		void popup() {
			auto w = width;
			// FIXME: suggestedDropdownHeight see below
			auto h = cast(int) this.options.length * Window.lineHeight + 8;

			auto coord = this.globalCoordinates();
			auto dropDown = new SimpleWindow(
				w, h,
				null, OpenGlOptions.no, Resizability.fixedSize, WindowTypes.dropdownMenu, WindowFlags.dontAutoShow, parentWindow ? parentWindow.win : null);

			dropDown.move(coord.x, coord.y + this.height);

			{
				auto cs = getComputedStyle();
				auto painter = dropDown.draw();
				draw3dFrame(0, 0, w, h, painter, FrameStyle.risen, getComputedStyle().background.color);
				auto p = Point(4, 4);
				painter.outlineColor = cs.foregroundColor;
				foreach(option; options) {
					painter.drawText(p, option);
					p.y += Window.lineHeight;
				}
			}

			dropDown.setEventHandlers(
				(MouseEvent event) {
					if(event.type == MouseEventType.buttonReleased) {
						dropDown.close();
						auto element = (event.y - 4) / Window.lineHeight;
						if(element >= 0 && element <= options.length) {
							selection = element;

							fireChangeEvent();
						}
					}
				}
			);

			dropDown.show();
			dropDown.grabInput();
		}

	}
}

/++
	A drop-down list where the user must select one of the
	given options. Like `<select>` in HTML.
+/
class DropDownSelection : ComboboxBase {
	this(Widget parent) {
		version(win32_widgets)
			super(3 /* CBS_DROPDOWNLIST */ | WS_VSCROLL, parent);
		else version(custom_widgets) {
			super(parent);

			addEventListener("focus", () { this.redraw; });
			addEventListener("blur", () { this.redraw; });
			addEventListener(EventType.change, () { this.redraw; });
			addEventListener("mousedown", () { this.focus(); this.popup(); });
			addEventListener((KeyDownEvent event) {
				if(event.key == Key.Space)
					popup();
			});
		} else static assert(false);
	}

	mixin Padding!q{2};
	static class Style : Widget.Style {
		override FrameStyle borderStyle() { return FrameStyle.risen; }
	}
	mixin OverrideStyle!Style;

	version(custom_widgets)
	override Rectangle paintContent(WidgetPainter painter, const Rectangle bounds) {
		auto cs = getComputedStyle();

		painter.drawText(bounds.upperLeft, selection == -1 ? "" : options[selection]);

		painter.outlineColor = cs.foregroundColor;
		painter.fillColor = cs.foregroundColor;
		Point[4] triangle;
		enum padding = 6;
		enum paddingV = 7;
		enum triangleWidth = 10;
		triangle[0] = Point(width - padding - triangleWidth, paddingV);
		triangle[1] = Point(width - padding - triangleWidth / 2, height - paddingV);
		triangle[2] = Point(width - padding - 0, paddingV);
		triangle[3] = triangle[0];
		painter.drawPolygon(triangle[]);

		return bounds;
	}

	version(win32_widgets)
	override void registerMovement() {
		version(win32_widgets) {
			if(hwnd) {
				auto pos = getChildPositionRelativeToParentHwnd(this);
				// the height given to this from Windows' perspective is supposed
				// to include the drop down's height. so I add to it to give some
				// room for that.
				// FIXME: maybe make the subclass provide a suggestedDropdownHeight thing
				MoveWindow(hwnd, pos[0], pos[1], width, height + 200, true);
			}
		}
		sendResizeEvent();
	}
}

/++
	A text box with a drop down arrow listing selections.
	The user can choose from the list, or type their own.
+/
class FreeEntrySelection : ComboboxBase {
	this(Widget parent) {
		version(win32_widgets)
			super(2 /* CBS_DROPDOWN */, parent);
		else version(custom_widgets) {
			super(parent);
			auto hl = new HorizontalLayout(this);
			lineEdit = new LineEdit(hl);

			tabStop = false;

			lineEdit.addEventListener("focus", &lineEdit.selectAll);

			auto btn = new class ArrowButton {
				this() {
					super(ArrowDirection.down, hl);
				}
				override int maxHeight() {
					return int.max;
				}
			};
			//btn.addDirectEventListener("focus", &lineEdit.focus);
			btn.addEventListener("triggered", &this.popup);
			addEventListener(EventType.change, (Event event) {
				lineEdit.content = event.stringValue;
				lineEdit.focus();
				redraw();
			});
		}
		else static assert(false);
	}

	version(custom_widgets) {
		LineEdit lineEdit;
	}
}

/++
	A combination of free entry with a list below it.
+/
class ComboBox : ComboboxBase {
	this(Widget parent) {
		version(win32_widgets)
			super(1 /* CBS_SIMPLE */ | CBS_NOINTEGRALHEIGHT, parent);
		else version(custom_widgets) {
			super(parent);
			lineEdit = new LineEdit(this);
			listWidget = new ListWidget(this);
			listWidget.multiSelect = false;
			listWidget.addEventListener(EventType.change, delegate(Widget, Event) {
				string c = null;
				foreach(option; listWidget.options)
					if(option.selected) {
						c = option.label;
						break;
					}
				lineEdit.content = c;
			});

			listWidget.tabStop = false;
			this.tabStop = false;
			listWidget.addEventListener("focus", &lineEdit.focus);
			this.addEventListener("focus", &lineEdit.focus);

			addDirectEventListener(EventType.change, {
				listWidget.setSelection(selection);
				if(selection != -1)
					lineEdit.content = options[selection];
				lineEdit.focus();
				redraw();
			});

			lineEdit.addEventListener("focus", &lineEdit.selectAll);

			listWidget.addDirectEventListener(EventType.change, {
				int set = -1;
				foreach(idx, opt; listWidget.options)
					if(opt.selected) {
						set = cast(int) idx;
						break;
					}
				if(set != selection)
					this.setSelection(set);
			});
		} else static assert(false);
	}

	override int minHeight() { return Window.lineHeight * 3; }
	override int maxHeight() { return int.max; }
	override int heightStretchiness() { return 5; }

	version(custom_widgets) {
		LineEdit lineEdit;
		ListWidget listWidget;

		override void addOption(string s) {
			listWidget.options ~= ListWidget.Option(s);
			ComboboxBase.addOption(s);
		}
	}
}

/+
class Spinner : Widget {
	version(win32_widgets)
	this(Widget parent) {
		super(parent);
		parentWindow = parent.parentWindow;
		auto hlayout = new HorizontalLayout(this);
		lineEdit = new LineEdit(hlayout);
		upDownControl = new UpDownControl(hlayout);
	}

	LineEdit lineEdit;
	UpDownControl upDownControl;
}

class UpDownControl : Widget {
	version(win32_widgets)
	this(Widget parent) {
		super(parent);
		parentWindow = parent.parentWindow;
		createWin32Window(this, "msctls_updown32"w, null, 4/*UDS_ALIGNRIGHT*/| 2 /* UDS_SETBUDDYINT */ | 16 /* UDS_AUTOBUDDY */ | 32 /* UDS_ARROWKEYS */);
	}

	override int minHeight() { return Window.lineHeight; }
	override int maxHeight() { return Window.lineHeight * 3/2; }

	override int minWidth() { return Window.lineHeight * 3/2; }
	override int maxWidth() { return Window.lineHeight * 3/2; }
}
+/

/+
class DataView : Widget {
	// this is the omnibus data viewer
	// the internal data layout is something like:
	// string[string][] but also each node can have parents
}
+/


// http://msdn.microsoft.com/en-us/library/windows/desktop/bb775491(v=vs.85).aspx#PROGRESS_CLASS

// http://svn.dsource.org/projects/bindings/trunk/win32/commctrl.d

// FIXME: menus should prolly capture the mouse. ugh i kno.
/*
	TextEdit needs:

	* caret manipulation
	* selection control
	* convenience functions for appendText, insertText, insertTextAtCaret, etc.

	For example:

	connect(paste, &textEdit.insertTextAtCaret);

	would be nice.



	I kinda want an omnibus dataview that combines list, tree,
	and table - it can be switched dynamically between them.

	Flattening policy: only show top level, show recursive, show grouped
	List styles: plain list (e.g. <ul>), tiles (some details next to it), icons (like Windows explorer)

	Single select, multi select, organization, drag+drop
*/

//static if(UsingSimpledisplayX11)
version(win32_widgets) {}
else version(custom_widgets) {
	enum scrollClickRepeatInterval = 50;

deprecated("Get these properties off `Widget.getComputedStyle` instead. The defaults are now set in the `WidgetPainter.visualTheme`.") {
	enum windowBackgroundColor = Color(212, 212, 212); // used to be 192
	enum activeTabColor = lightAccentColor;
	enum hoveringColor = Color(228, 228, 228);
	enum buttonColor = windowBackgroundColor;
	enum depressedButtonColor = darkAccentColor;
	enum activeListXorColor = Color(255, 255, 127);
	enum progressBarColor = Color(0, 0, 128);
	enum activeMenuItemColor = Color(0, 0, 128);

}}
else static assert(false);
deprecated("Get these properties off the `visualTheme` instead.") {
	// these are used by horizontal rule so not just custom_widgets. for now at least.
	enum darkAccentColor = Color(172, 172, 172);
	enum lightAccentColor = Color(223, 223, 223); // used to be 223
}

private const(wchar)* toWstringzInternal(in char[] s) {
	wchar[] str;
	str.reserve(s.length + 1);
	foreach(dchar ch; s)
		str ~= ch;
	str ~= '\0';
	return str.ptr;
}

static if(SimpledisplayTimerAvailable)
void setClickRepeat(Widget w, int interval, int delay = 250) {
	Timer timer;
	int delayRemaining = delay / interval;
	if(delayRemaining <= 1)
		delayRemaining = 2;

	immutable originalDelayRemaining = delayRemaining;

	w.addDirectEventListener("mousedown", (Event ev) {
		if(ev.srcElement !is w)
			return;
		if(timer !is null) {
			timer.destroy();
			timer = null;
		}
		delayRemaining = originalDelayRemaining;
		timer = new Timer(interval, () {
			if(delayRemaining > 0)
				delayRemaining--;
			else {
				auto ev = new ClickEvent(w);
				ev.sendDirectly();
			}
		});
	});

	w.addDirectEventListener("mouseup", (Event ev) {
		if(ev.srcElement !is w)
			return;
		if(timer !is null) {
			timer.destroy();
			timer = null;
		}
	});

	w.addDirectEventListener("mouseleave", (Event ev) {
		if(ev.srcElement !is w)
			return;
		if(timer !is null) {
			timer.destroy();
			timer = null;
		}
	});

}
else
void setClickRepeat(Widget w, int interval, int delay = 250) {}

enum FrameStyle {
	none, ///
	risen, /// a 3d pop-out effect (think Windows 95 button)
	sunk, /// a 3d sunken effect (think Windows 95 button as you click on it)
	solid, ///
	dotted, ///
	fantasy, /// a style based on a popular fantasy video game
}

version(custom_widgets)
deprecated
void draw3dFrame(Widget widget, ScreenPainter painter, FrameStyle style) {
	draw3dFrame(0, 0, widget.width, widget.height, painter, style, WidgetPainter.visualTheme.windowBackgroundColor);
}

version(custom_widgets)
void draw3dFrame(Widget widget, ScreenPainter painter, FrameStyle style, Color background) {
	draw3dFrame(0, 0, widget.width, widget.height, painter, style, background);
}

version(custom_widgets)
deprecated
void draw3dFrame(int x, int y, int width, int height, ScreenPainter painter, FrameStyle style) {
	draw3dFrame(x, y, width, height, painter, style, WidgetPainter.visualTheme.windowBackgroundColor);
}

int draw3dFrame(int x, int y, int width, int height, ScreenPainter painter, FrameStyle style, Color background, Color border = Color.transparent) {
	int borderWidth;
	final switch(style) {
		case FrameStyle.sunk, FrameStyle.risen:
			// outer layer
			painter.outlineColor = style == FrameStyle.sunk ? Color.white : Color.black;
			borderWidth = 2;
		break;
		case FrameStyle.none:
			painter.outlineColor = background;
			borderWidth = 0;
		break;
		case FrameStyle.solid:
			painter.pen = Pen(border, 1);
			borderWidth = 1;
		break;
		case FrameStyle.dotted:
			painter.pen = Pen(border, 1, Pen.Style.Dotted);
			borderWidth = 1;
		break;
		case FrameStyle.fantasy:
			painter.pen = Pen(border, 3);
			borderWidth = 3;
		break;
	}

	painter.fillColor = background;
	painter.drawRectangle(Point(x + 0, y + 0), width, height);


	if(style == FrameStyle.sunk || style == FrameStyle.risen) {
		// 3d effect
		auto vt = WidgetPainter.visualTheme;

		painter.outlineColor = (style == FrameStyle.sunk) ? vt.darkAccentColor : vt.lightAccentColor;
		painter.drawLine(Point(x + 0, y + 0), Point(x + width, y + 0));
		painter.drawLine(Point(x + 0, y + 0), Point(x + 0, y + height - 1));

		// inner layer
		//right, bottom
		painter.outlineColor = (style == FrameStyle.sunk) ? vt.lightAccentColor : vt.darkAccentColor;
		painter.drawLine(Point(x + width - 2, y + 2), Point(x + width - 2, y + height - 2));
		painter.drawLine(Point(x + 2, y + height - 2), Point(x + width - 2, y + height - 2));
		// left, top
		painter.outlineColor = (style == FrameStyle.sunk) ? Color.black : Color.white;
		painter.drawLine(Point(x + 1, y + 1), Point(x + width, y + 1));
		painter.drawLine(Point(x + 1, y + 1), Point(x + 1, y + height - 2));
	} else if(style == FrameStyle.fantasy) {
		painter.pen = Pen(Color.white, 1, Pen.Style.Solid);
		painter.fillColor = Color.transparent;
		painter.drawRectangle(Point(x + 1, y + 1), Point(x + width - 1, y + height - 1));
	}

	return borderWidth;
}

/++
	An `Action` represents some kind of user action they can trigger through menu options, toolbars, hotkeys, and similar mechanisms. The text label, icon, and handlers are centrally held here instead of repeated in each UI element.

	See_Also:
		[MenuItem]
		[ToolButton]
		[Menu.addItem]
+/
class Action {
	version(win32_widgets) {
		private int id;
		private static int lastId = 9000;
		private static Action[int] mapping;
	}

	KeyEvent accelerator;

	// FIXME: disable message
	// and toggle thing?
	// ??? and trigger arguments too ???

	/++
		Params:
			label = the textual label
			icon = icon ID. See [GenericIcons]. There is currently no way to do custom icons.
			triggered = initial handler, more can be added via the [triggered] member.
	+/
	this(string label, ushort icon = 0, void delegate() triggered = null) {
		this.label = label;
		this.iconId = icon;
		if(triggered !is null)
			this.triggered ~= triggered;
		version(win32_widgets) {
			id = ++lastId;
			mapping[id] = this;
		}
	}

	private string label;
	private ushort iconId;
	// icon

	// when it is triggered, the triggered event is fired on the window
	/// The list of handlers when it is triggered.
	void delegate()[] triggered;
}

/*
	plan:
		keyboard accelerators

		* menus (and popups and tooltips)
		* status bar
		* toolbars and buttons

		sortable table view

		maybe notification area icons
		basic clipboard

		* radio box
		splitter
		toggle buttons (optionally mutually exclusive, like in Paint)
		label, rich text display, multi line plain text (selectable)
		* fieldset
		* nestable grid layout
		single line text input
		* multi line text input
		slider
		spinner
		list box
		drop down
		combo box
		auto complete box
		* progress bar

		terminal window/widget (on unix it might even be a pty but really idk)

		ok button
		cancel button

		keyboard hotkeys

		scroll widget

		event redirections and network transparency
		script integration
*/


/*
	MENUS

	auto bar = new MenuBar(window);
	window.menuBar = bar;

	auto fileMenu = bar.addItem(new Menu("&File"));
	fileMenu.addItem(new MenuItem("&Exit"));


	EVENTS

	For controls, you should usually use "triggered" rather than "click", etc., because
	triggered handles both keyboard (focus and press as well as hotkeys) and mouse activation.
	This is the case on menus and pushbuttons.

	"click", on the other hand, currently only fires when it is literally clicked by the mouse.
*/


/*
enum LinePreference {
	AlwaysOnOwnLine, // always on its own line
	PreferOwnLine, // it will always start a new line, and if max width <= line width, it will expand all the way
	PreferToShareLine, // does not force new line, and if the next child likes to share too, they will div it up evenly. otherwise, it will expand as much as it can
}
*/

/++
	Convenience mixin for overriding all four sides of margin or padding in a [Widget] with the same code. It mixes in the given string as the return value of the four overridden methods.

	---
	class MyWidget : Widget {
		this(Widget parent) { super(parent); }

		// set paddingLeft, paddingRight, paddingTop, and paddingBottom all to `return 4;` in one go:
		mixin Padding!q{4};

		// set marginLeft, marginRight, marginTop, and marginBottom all to `return 8;` in one go:
		mixin Margin!q{8};

		// but if I specify one outside, it overrides the override, so now marginLeft is 2,
		// while Top/Bottom/Right remain 8 from the mixin above.
		override int marginLeft() { return 2; }
	}
	---


	The minigui layout model is based on the web's CSS box model. The layout engine* arranges widgets based on their margin for separation and assigns them a size based on thier preferences (e.g. [Widget.minHeight]) and the available space. Widgets are assigned a size by the layout engine. Inside this size, they have a border (see [Widget.Style.borderWidth]), then padding space, and then their content. Their content box may also have an outline drawn on top of it (see [Widget.Style.outlineStyle]).

	Padding is the area inside a widget where its background is drawn, but the content avoids.

	Margin is the area between widgets. The algorithm is the spacing between any two widgets is the max of their adjacent margins (not the sum!).

	* Some widgets do not participate in placement, e.g. [StaticPosition], and some layout systems do their own separate thing too; ultimately, these properties are just hints to the layout function and you can always implement your own to do whatever you want. But this statement is still mostly true.
+/
mixin template Padding(string code) {
	override int paddingLeft() { return mixin(code);}
	override int paddingRight() { return mixin(code);}
	override int paddingTop() { return mixin(code);}
	override int paddingBottom() { return mixin(code);}
}

/// ditto
mixin template Margin(string code) {
	override int marginLeft() { return mixin(code);}
	override int marginRight() { return mixin(code);}
	override int marginTop() { return mixin(code);}
	override int marginBottom() { return mixin(code);}
}

private
void recomputeChildLayout(string relevantMeasure)(Widget parent) {
	enum calcingV = relevantMeasure == "height";

	parent.registerMovement();

	if(parent.children.length == 0)
		return;

	auto parentStyle = parent.getComputedStyle();

	enum firstThingy = relevantMeasure == "height" ? "Top" : "Left";
	enum secondThingy = relevantMeasure == "height" ? "Bottom" : "Right";

	enum otherFirstThingy = relevantMeasure == "height" ? "Left" : "Top";
	enum otherSecondThingy = relevantMeasure == "height" ? "Right" : "Bottom";

	// my own width and height should already be set by the caller of this function...
	int spaceRemaining = mixin("parent." ~ relevantMeasure) -
		mixin("parentStyle.padding"~firstThingy~"()") -
		mixin("parentStyle.padding"~secondThingy~"()");

	int stretchinessSum;
	int stretchyChildSum;
	int lastMargin = 0;

	// set initial size
	foreach(child; parent.children) {

		auto childStyle = child.getComputedStyle();

		if(cast(StaticPosition) child)
			continue;
		if(child.hidden)
			continue;

		static if(calcingV) {
			child.width = parent.width -
				mixin("childStyle.margin"~otherFirstThingy~"()") -
				mixin("childStyle.margin"~otherSecondThingy~"()") -
				mixin("parentStyle.padding"~otherFirstThingy~"()") -
				mixin("parentStyle.padding"~otherSecondThingy~"()");

			if(child.width < 0)
				child.width = 0;
			if(child.width > childStyle.maxWidth())
				child.width = childStyle.maxWidth();
			child.height = childStyle.minHeight();
		} else {
			child.height = parent.height -
				mixin("childStyle.margin"~firstThingy~"()") -
				mixin("childStyle.margin"~secondThingy~"()") -
				mixin("parentStyle.padding"~firstThingy~"()") -
				mixin("parentStyle.padding"~secondThingy~"()");
			if(child.height < 0)
				child.height = 0;
			if(child.height > childStyle.maxHeight())
				child.height = childStyle.maxHeight();
			child.width = childStyle.minWidth();
		}

		spaceRemaining -= mixin("child." ~ relevantMeasure);

		int thisMargin = mymax(lastMargin, mixin("childStyle.margin"~firstThingy~"()"));
		auto margin = mixin("childStyle.margin" ~ secondThingy ~ "()");
		lastMargin = margin;
		spaceRemaining -= thisMargin + margin;
		auto s = mixin("child." ~ relevantMeasure ~ "Stretchiness()");
		stretchinessSum += s;
		if(s > 0)
			stretchyChildSum++;
	}

	// stretch to fill space
	while(spaceRemaining > 0 && stretchinessSum && stretchyChildSum) {
		//import std.stdio; writeln("str ", stretchinessSum);
		auto spacePerChild = spaceRemaining / stretchinessSum;
		bool spreadEvenly;
		bool giveToBiggest;
		if(spacePerChild <= 0) {
			spacePerChild = spaceRemaining / stretchyChildSum;
			spreadEvenly = true;
		}
		if(spacePerChild <= 0) {
			giveToBiggest = true;
		}
		int previousSpaceRemaining = spaceRemaining;
		stretchinessSum = 0;
		Widget mostStretchy;
		int mostStretchyS;
		foreach(child; parent.children) {
			auto childStyle = child.getComputedStyle();
			if(cast(StaticPosition) child)
				continue;
			if(child.hidden)
				continue;
			static if(calcingV)
				auto maximum = childStyle.maxHeight();
			else
				auto maximum = childStyle.maxWidth();

			if(mixin("child." ~ relevantMeasure) >= maximum) {
				auto adj = mixin("child." ~ relevantMeasure) - maximum;
				mixin("child._" ~ relevantMeasure) -= adj;
				spaceRemaining += adj;
				continue;
			}
			auto s = mixin("child." ~ relevantMeasure ~ "Stretchiness()");
			if(s <= 0)
				continue;
			auto spaceAdjustment = spacePerChild * (spreadEvenly ? 1 : s);
			mixin("child._" ~ relevantMeasure) += spaceAdjustment;
			spaceRemaining -= spaceAdjustment;
			if(mixin("child." ~ relevantMeasure) > maximum) {
				auto diff = mixin("child." ~ relevantMeasure) - maximum;
				mixin("child._" ~ relevantMeasure) -= diff;
				spaceRemaining += diff;
			} else if(mixin("child._" ~ relevantMeasure) < maximum) {
				stretchinessSum += mixin("child." ~ relevantMeasure ~ "Stretchiness()");
				if(mostStretchy is null || s >= mostStretchyS) {
					mostStretchy = child;
					mostStretchyS = s;
				}
			}
		}

		if(giveToBiggest && mostStretchy !is null) {
			auto child = mostStretchy;
			auto childStyle = child.getComputedStyle();
			int spaceAdjustment = spaceRemaining;

			static if(calcingV)
				auto maximum = childStyle.maxHeight();
			else
				auto maximum = childStyle.maxWidth();

			mixin("child._" ~ relevantMeasure) += spaceAdjustment;
			spaceRemaining -= spaceAdjustment;
			if(mixin("child._" ~ relevantMeasure) > maximum) {
				auto diff = mixin("child." ~ relevantMeasure) - maximum;
				mixin("child._" ~ relevantMeasure) -= diff;
				spaceRemaining += diff;
			}
		}

		if(spaceRemaining == previousSpaceRemaining)
			break; // apparently nothing more we can do
	}

	// position
	lastMargin = 0;
	int currentPos = mixin("parent.padding"~firstThingy~"()");
	foreach(child; parent.children) {
		auto childStyle = child.getComputedStyle();
		if(cast(StaticPosition) child) {
			child.recomputeChildLayout();
			continue;
		}
		if(child.hidden)
			continue;
		auto margin = mixin("childStyle.margin" ~ secondThingy ~ "()");
		int thisMargin = mymax(lastMargin, mixin("childStyle.margin"~firstThingy~"()"));
		currentPos += thisMargin;
		static if(calcingV) {
			child.x = parentStyle.paddingLeft() + childStyle.marginLeft();
			child.y = currentPos;
		} else {
			child.x = currentPos;
			child.y = parentStyle.paddingTop() + childStyle.marginTop();

		}
		currentPos += mixin("child." ~ relevantMeasure);
		currentPos += margin;
		lastMargin = margin;

		child.recomputeChildLayout();
	}
}

int mymax(int a, int b) { return a > b ? a : b; }

// OK so we need to make getting at the native window stuff possible in simpledisplay.d
// and here, it must be integrable with the layout, the event system, and not be painted over.
version(win32_widgets) {
	extern(Windows)
	private
	LRESULT HookedWndProc(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam) nothrow {
		//import std.stdio; try { writeln(iMessage); } catch(Exception e) {};
		if(auto te = hWnd in Widget.nativeMapping) {
			try {

				te.hookedWndProc(iMessage, wParam, lParam);

				if(iMessage == WM_SETFOCUS) {
					auto lol = *te;
					while(lol !is null && lol.implicitlyCreated)
						lol = lol.parent;
					lol.focus();
					//(*te).parentWindow.focusedWidget = lol;
				}



				if(iMessage == WM_CTLCOLORBTN || iMessage == WM_CTLCOLORSTATIC) {
					SetBkMode(cast(HDC) wParam, TRANSPARENT);
					return cast(typeof(return)) GetSysColorBrush(COLOR_3DFACE); // this is the window background color...
						//GetStockObject(NULL_BRUSH);
				}


				auto pos = getChildPositionRelativeToParentOrigin(*te);
				lastDefaultPrevented = false;
				// try {import std.stdio; writeln(typeid(*te)); } catch(Exception e) {}
				if(SimpleWindow.triggerEvents(hWnd, iMessage, wParam, lParam, pos[0], pos[1], (*te).parentWindow.win) || !lastDefaultPrevented)
					return CallWindowProcW((*te).originalWindowProcedure, hWnd, iMessage, wParam, lParam);
				else {
					// it was something we recognized, should only call the window procedure if the default was not prevented
				}
			} catch(Exception e) {
				assert(0, e.toString());
			}
			return 0;
		}
		assert(0, "shouldn't be receiving messages for this window....");
		//import std.conv;
		//assert(0, to!string(hWnd) ~ " :: " ~ to!string(TextEdit.nativeMapping)); // not supposed to happen
	}

	extern(Windows)
	private
	LRESULT HookedWndProcBSGROUPBOX_HACK(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam) nothrow {
		if(iMessage == WM_ERASEBKGND) {
			auto dc = GetDC(hWnd);
			auto b = SelectObject(dc, GetSysColorBrush(COLOR_3DFACE));
			auto p = SelectObject(dc, GetStockObject(NULL_PEN));
			RECT r;
			GetWindowRect(hWnd, &r);
			// since the pen is null, to fill the whole space, we need the +1 on both.
			gdi.Rectangle(dc, 0, 0, r.right - r.left + 1, r.bottom - r.top + 1);
			SelectObject(dc, p);
			SelectObject(dc, b);
			ReleaseDC(hWnd, dc);
			return 1;
		}
		return HookedWndProc(hWnd, iMessage, wParam, lParam);
	}

	/++
		Calls MS Windows' CreateWindowExW function to create a native backing for the given widget. It will create
		needed mappings, window procedure hooks, and other private member variables needed to tie it into the rest
		of minigui's expectations.

		This should be called in your widget's constructor AFTER you call `super(parent);`. The parent window
		member MUST already be initialized for this function to succeed, which is done by [Widget]'s base constructor.

		It assumes `className` is zero-terminated. It should come from a `"wide string literal"w`.

		To check if you can use this, use `static if(UsingWin32Widgets)`.
	+/
	void createWin32Window(Widget p, const(wchar)[] className, string windowText, DWORD style, DWORD extStyle = 0) {
		assert(p.parentWindow !is null);
		assert(p.parentWindow.win.impl.hwnd !is null);

		auto bsgroupbox = style == BS_GROUPBOX;

		HWND phwnd;

		auto wtf = p.parent;
		while(wtf) {
			if(wtf.hwnd !is null) {
				phwnd = wtf.hwnd;
				break;
			}
			wtf = wtf.parent;
		}

		if(phwnd is null)
			phwnd = p.parentWindow.win.impl.hwnd;

		assert(phwnd !is null);

		WCharzBuffer wt = WCharzBuffer(windowText);

		style |= WS_VISIBLE | WS_CHILD;
		//if(className != WC_TABCONTROL)
			style |= WS_CLIPCHILDREN | WS_CLIPSIBLINGS;
		p.hwnd = CreateWindowExW(extStyle, className.ptr, wt.ptr, style,
				CW_USEDEFAULT, CW_USEDEFAULT, 100, 100,
				phwnd, null, cast(HINSTANCE) GetModuleHandle(null), null);

		assert(p.hwnd !is null);


		static HFONT font;
		if(font is null) {
			NONCLIENTMETRICS params;
			params.cbSize = params.sizeof;
			if(SystemParametersInfo(SPI_GETNONCLIENTMETRICS, params.sizeof, &params, 0)) {
				font = CreateFontIndirect(&params.lfMessageFont);
			}
		}

		if(font)
			SendMessage(p.hwnd, WM_SETFONT, cast(uint) font, true);

		p.simpleWindowWrappingHwnd = new SimpleWindow(p.hwnd);
		p.simpleWindowWrappingHwnd.beingOpenKeepsAppOpen = false;
		Widget.nativeMapping[p.hwnd] = p;

		if(bsgroupbox)
		p.originalWindowProcedure = cast(WNDPROC) SetWindowLongPtr(p.hwnd, GWL_WNDPROC, cast(size_t) &HookedWndProcBSGROUPBOX_HACK);
		else
		p.originalWindowProcedure = cast(WNDPROC) SetWindowLongPtr(p.hwnd, GWL_WNDPROC, cast(size_t) &HookedWndProc);

		EnumChildWindows(p.hwnd, &childHandler, cast(LPARAM) cast(void*) p);

		p.registerMovement();
	}
}

version(win32_widgets)
private
extern(Windows) BOOL childHandler(HWND hwnd, LPARAM lparam) {
	if(hwnd is null || hwnd in Widget.nativeMapping)
		return true;
	auto parent = cast(Widget) cast(void*) lparam;
	Widget p = new Widget(null);
	p._parent = parent;
	p.parentWindow = parent.parentWindow;
	p.hwnd = hwnd;
	p.implicitlyCreated = true;
	Widget.nativeMapping[p.hwnd] = p;
	p.originalWindowProcedure = cast(WNDPROC) SetWindowLongPtr(p.hwnd, GWL_WNDPROC, cast(size_t) &HookedWndProc);
	return true;
}

/++
	Encapsulates the simpledisplay [ScreenPainter] for use on a [Widget], with [VisualTheme] and invalidated area awareness.
+/
struct WidgetPainter {
	this(ScreenPainter screenPainter, Widget drawingUpon) {
		this.drawingUpon = drawingUpon;
		this.screenPainter = screenPainter;
		if(auto font = visualTheme.defaultFontCached)
			this.screenPainter.setFont(font);
	}

	///
	ScreenPainter screenPainter;
	/// Forward to the screen painter for other methods
	alias screenPainter this;

	private Widget drawingUpon;

	/++
		This is the list of rectangles that actually need to be redrawn.

		Not actually implemented yet.
	+/
	Rectangle[] invalidatedRectangles;

	private static BaseVisualTheme _visualTheme;

	/++
		Functions to access the visual theme and helpers to easily use it.

		These are aware of the current widget's computed style out of the theme.
	+/
	static @property BaseVisualTheme visualTheme() {
		if(_visualTheme is null)
			_visualTheme = new DefaultVisualTheme();
		return _visualTheme;
	}

	/// ditto
	static @property void visualTheme(BaseVisualTheme theme) {
		_visualTheme = theme;
	}

	/// ditto
	Color themeForeground() {
		return drawingUpon.getComputedStyle().foregroundColor();
	}

	/// ditto
	Color themeBackground() {
		return drawingUpon.getComputedStyle().background.color;
	}

	int isDarkTheme() {
		return 0; // unspecified, yes, no as enum. FIXME
	}

	/++
		Draws the general pattern of a widget if you don't need anything particularly special and/or control the other details through your widget's style theme hints.

		It gives your draw delegate a [Rectangle] representing the coordinates inside your border and padding.

		If you change teh clip rectangle, you should change it back before you return.


		The sequence it uses is:
			background
			content (delegated to you)
			border
			focused outline
			selected overlay

		Example code:

		---
		void paint(WidgetPainter painter) {
			painter.drawThemed((bounds) {
				return bounds; // if the selection overlay should be contained, you can return it here.
			});
		}
		---
	+/
	void drawThemed(scope Rectangle delegate(const Rectangle bounds) drawBody) {
		drawThemed((WidgetPainter painter, const Rectangle bounds) {
			return drawBody(bounds);
		});
	}
	// this overload is actually mroe for setting the delegate to a virtual function
	void drawThemed(scope Rectangle delegate(WidgetPainter painter, const Rectangle bounds) drawBody) {
		Rectangle rect = Rectangle(0, 0, drawingUpon.width, drawingUpon.height);

		auto cs = drawingUpon.getComputedStyle();

		auto bg = cs.background.color;

		auto borderWidth = draw3dFrame(0, 0, drawingUpon.width, drawingUpon.height, this, cs.borderStyle, bg, cs.borderColor);

		rect.left += borderWidth;
		rect.right -= borderWidth;
		rect.top += borderWidth;
		rect.bottom -= borderWidth;

		auto insideBorderRect = rect;

		rect.left += cs.paddingLeft;
		rect.right -= cs.paddingRight;
		rect.top += cs.paddingTop;
		rect.bottom += cs.paddingBottom;

		this.outlineColor = this.themeForeground;
		this.fillColor = bg;

		rect = drawBody(this, rect);

		if(auto os = cs.outlineStyle()) {
			this.pen = Pen(cs.outlineColor(), 1, os == FrameStyle.dotted ? Pen.Style.Dotted : Pen.Style.Solid);
			this.fillColor = Color.transparent;
			this.drawRectangle(insideBorderRect);
		}
	}

	/++
		First, draw the background.
		Then draw your content.
		Next, draw the border.
		And the focused indicator.
		And the is-selected box.

		If it is focused i can draw the outline too...

		If selected i can even do the xor action but that's at the end.
	+/
	void drawThemeBackground() {

	}

	void drawThemeBorder() {

	}

	// all this stuff is a dangerous experiment....
	static class ScriptableVersion {
		ScreenPainterImplementation* p;
		int originX, originY;

		@scriptable:
		void drawRectangle(int x, int y, int width, int height) {
			p.drawRectangle(x + originX, y + originY, width, height);
		}
		void drawLine(int x1, int y1, int x2, int y2) {
			p.drawLine(x1 + originX, y1 + originY, x2 + originX, y2 + originY);
		}
		void drawText(int x, int y, string text) {
			p.drawText(x + originX, y + originY, 100000, 100000, text, 0);
		}
		void setOutlineColor(int r, int g, int b) {
			p.pen = Pen(Color(r,g,b), 1);
		}
		void setFillColor(int r, int g, int b) {
			p.fillColor = Color(r,g,b);
		}
	}

	ScriptableVersion toArsdJsvar() {
		auto sv = new ScriptableVersion;
		sv.p = this.screenPainter.impl;
		sv.originX = this.screenPainter.originX;
		sv.originY = this.screenPainter.originY;
		return sv;
	}

	static WidgetPainter fromJsVar(T)(T t) {
		return WidgetPainter.init;
	}
	// done..........
}


struct Style {
	static struct helper(string m, T) {
		enum method = m;
		T v;

		mixin template MethodOverride(typeof(this) v) {
			mixin("override typeof(v.v) "~v.method~"() { return v.v; }");
		}
	}

	static auto opDispatch(string method, T)(T value) {
		return helper!(method, T)(value);
	}
}

/++
	Implementation detail of the [ControlledBy] UDA.

	History:
		Added Oct 28, 2020
+/
struct ControlledBy_(T, Args...) {
	Args args;

	static if(Args.length)
	this(Args args) {
		this.args = args;
	}

	private T construct(Widget parent) {
		return new T(args, parent);
	}
}

/++
	User-defined attribute you can add to struct members contrlled by [addDataControllerWidget] or [dialog] to tell which widget you want created for them.

	History:
		Added Oct 28, 2020
+/
auto ControlledBy(T, Args...)(Args args) {
	return ControlledBy_!(T, Args)(args);
}

struct ContainerMeta {
	string name;
	ContainerMeta[] children;
	Widget function(Widget parent) factory;

	Widget instantiate(Widget parent) {
		auto n = factory(parent);
		n.name = name;
		foreach(child; children)
			child.instantiate(n);
		return n;
	}
}

/++
	This is a helper for [addDataControllerWidget]. You can use it as a UDA on the type. See
	http://dpldocs.info/this-week-in-d/Blog.Posted_2020_11_02.html for more information.

	Please note that as of May 28, 2021, a dmd bug prevents this from compiling on module-level
	structures. It works fine on structs declared inside functions though.

	See: https://issues.dlang.org/show_bug.cgi?id=21984
+/
template Container(CArgs...) {
	static if(CArgs.length && is(CArgs[0] : Widget)) {
		private alias Super = CArgs[0];
		private alias CArgs2 = CArgs[1 .. $];
	} else {
		private alias Super = Layout;
		private alias CArgs2 = CArgs;
	}

	class Container : Super {
		this(Widget parent) { super(parent); }

		// just to partially support old gdc versions
		version(GNU) {
			static if(CArgs2.length >= 1) { enum tmp0 = CArgs2[0]; mixin typeof(tmp0).MethodOverride!(CArgs2[0]); }
			static if(CArgs2.length >= 2) { enum tmp1 = CArgs2[1]; mixin typeof(tmp1).MethodOverride!(CArgs2[1]); }
			static if(CArgs2.length >= 3) { enum tmp2 = CArgs2[2]; mixin typeof(tmp2).MethodOverride!(CArgs2[2]); }
			static if(CArgs2.length > 3) static assert(0, "only a few overrides like this supported on your compiler version at this time");
		} else mixin(q{
			static foreach(Arg; CArgs2) {
				mixin Arg.MethodOverride!(Arg);
			}
		});

		static ContainerMeta opCall(string name, ContainerMeta[] children...) {
			return ContainerMeta(
				name,
				children.dup,
				function (Widget parent) { return new typeof(this)(parent); }
			);
		}

		static ContainerMeta opCall(ContainerMeta[] children...) {
			return opCall(null, children);
		}
	}
}

/++
	The data controller widget is created by reflecting over the given
	data type. You can use [ControlledBy] as a UDA on a struct or
	just let it create things automatically.

	Unlike [dialog], this uses real-time updating of the data and
	you add it to another window yourself.

	---
		struct Test {
			int x;
			int y;
		}

		auto window = new Window();
		auto dcw = new DataControllerWidget!Test(new Test, window);
	---

	The way it works is any public members are given a widget based
	on their data type, and public methods trigger an action button
	if no relevant parameters or a dialog action if it does have
	parameters, similar to the [menu] facility.

	If you change data programmatically, without going through the
	DataControllerWidget methods, you will have to tell it something
	has changed and it needs to redraw. This is done with the `invalidate`
	method.

	History:
		Added Oct 28, 2020
+/
/// Group: generating_from_code
class DataControllerWidget(T) : WidgetContainer {
	static if(is(T == class) || is(T : const E[], E))
		private alias Tref = T;
	else
		private alias Tref = T*;

	Tref datum;

	/++
		See_also: [addDataControllerWidget]
	+/
	this(Tref datum, Widget parent) {
		this.datum = datum;

		Widget cp = this;

		super(parent);

		foreach(attr; __traits(getAttributes, T))
			static if(is(typeof(attr) == ContainerMeta)) {
				cp = attr.instantiate(this);
			}

		auto def = this.getByName("default");
		if(def !is null)
			cp = def;

		Widget helper(string name) {
			auto maybe = this.getByName(name);
			if(maybe is null)
				return cp;
			return maybe;

		}

		foreach(member; __traits(allMembers, T))
		static if(member != "this") // wtf https://issues.dlang.org/show_bug.cgi?id=22011
		static if(__traits(getProtection, __traits(getMember, this.datum, member)) == "public") {
			void delegate() update;

			auto w = widgetFor!(__traits(getMember, T, member))(&__traits(getMember, this.datum, member), helper(member), update);

			if(update)
				updaters ~= update;

			static if(is(typeof(__traits(getMember, this.datum, member)) == function)) {
				w.addEventListener("triggered", delegate() {
					makeAutomaticHandler!(__traits(getMember, this.datum, member))(&__traits(getMember, this.datum, member))();
					notifyDataUpdated();
				});
			} else static if(is(typeof(w.isChecked) == bool)) {
				w.addEventListener(EventType.change, (Event ev) {
					__traits(getMember, this.datum, member) = w.isChecked;
				});
			} else static if(is(typeof(w.value) == string) || is(typeof(w.content) == string)) {
				w.addEventListener("change", (Event e) { genericSetValue(&__traits(getMember, this.datum, member), e.stringValue); } );
			} else static if(is(typeof(w.value) == int)) {
				w.addEventListener("change", (Event e) { genericSetValue(&__traits(getMember, this.datum, member), e.intValue); } );
			} else {
				static assert(0, "unsupported type " ~ typeof(__traits(getMember, this.datum, member)).stringof ~ " " ~ typeof(w).stringof);
			}
		}
	}

	/++
		If you modify the data in the structure directly, you need to call this to update the UI and propagate any change messages.

		History:
			Added May 28, 2021
	+/
	void notifyDataUpdated() {
		foreach(updater; updaters)
			updater();

		this.emit!(ChangeEvent!void)(delegate{});
	}

	private Widget[string] memberWidgets;
	private void delegate()[] updaters;

	mixin Emits!(ChangeEvent!void);
}

private int saturatedSum(int[] values...) {
	int sum;
	foreach(value; values) {
		if(value == int.max)
			return int.max;
		sum += value;
	}
	return sum;
}

void genericSetValue(T, W)(T* where, W what) {
	import std.conv;
	*where = to!T(what);
	//*where = cast(T) stringToLong(what);
}

/++
	Creates a widget for the value `tt`, which is pointed to at runtime by `valptr`, with the given parent.

	The `update` delegate can be called if you change `*valptr` to reflect those changes in the widget.

	Note that this creates the widget but does not attach any event handlers to it.
+/
private static auto widgetFor(alias tt, P)(P valptr, Widget parent, out void delegate() update) {

	string displayName = __traits(identifier, tt).beautify;

	static if(controlledByCount!tt == 1) {
		foreach(i, attr; __traits(getAttributes, tt)) {
			static if(is(typeof(attr) == ControlledBy_!(T, Args), T, Args...)) {
				auto w = attr.construct(parent);
				static if(__traits(compiles, w.setPosition(*valptr)))
					update = () { w.setPosition(*valptr); };
				else static if(__traits(compiles, w.setValue(*valptr)))
					update = () { w.setValue(*valptr); };

				if(update)
					update();
				return w;
			}
		}
	} else static if(controlledByCount!tt == 0) {
		static if(is(typeof(tt) == enum)) {
			// FIXME: update
			auto dds = new DropDownSelection(parent);
			foreach(idx, option; __traits(allMembers, typeof(tt))) {
				dds.addOption(option);
				if(__traits(getMember, typeof(tt), option) == *valptr)
					dds.setSelection(cast(int) idx);
			}
			return dds;
		} else static if(is(typeof(tt) == bool)) {
			auto box = new Checkbox(displayName, parent);
			update = () { box.isChecked = *valptr; };
			update();
			return box;
		} else static if(is(typeof(tt) : const long)) {
			auto le = new LabeledLineEdit(displayName, parent);
			update = () { le.content = toInternal!string(*valptr); };
			update();
			return le;
		} else static if(is(typeof(tt) : const string)) {
			auto le = new LabeledLineEdit(displayName, parent);
			update = () { le.content = *valptr; };
			update();
			return le;
		} else static if(is(typeof(tt) == function)) {
			auto w = new Button(displayName, parent);
			return w;
		}
	} else static assert(0, "multiple controllers not yet supported");
}

private template controlledByCount(alias tt) {
	static int helper() {
		int count;
		foreach(i, attr; __traits(getAttributes, tt))
			static if(is(typeof(attr) == ControlledBy_!(T, Args), T, Args...))
				count++;
		return count;
	}

	enum controlledByCount = helper;
}

/++
	Intended for UFCS action like `window.addDataControllerWidget(new MyObject());`

	If you provide a `redrawOnChange` widget, it will automatically register a change event handler that calls that widget's redraw method.

	History:
		The `redrawOnChange` parameter was added on May 28, 2021.
+/
DataControllerWidget!T addDataControllerWidget(T)(Widget parent, T t, Widget redrawOnChange = null) if(is(T == class)) {
	auto dcw = new DataControllerWidget!T(t, parent);
	initializeDataControllerWidget(dcw, redrawOnChange);
	return dcw;
}

/// ditto
DataControllerWidget!T addDataControllerWidget(T)(Widget parent, T* t, Widget redrawOnChange = null) if(is(T == struct)) {
	auto dcw = new DataControllerWidget!T(t, parent);
	initializeDataControllerWidget(dcw, redrawOnChange);
	return dcw;
}

private void initializeDataControllerWidget(Widget w, Widget redrawOnChange) {
	if(redrawOnChange !is null)
		w.addEventListener("change", delegate() { redrawOnChange.redraw(); });
}

/++
	Get this through [Widget.getComputedStyle]. It provides access to the [Widget.Style] style hints and [Widget] layout hints, possibly modified through the [VisualTheme], through a unifed interface.

	History:
		Finalized on June 3, 2021 for the dub v10.0 release
+/
struct StyleInformation {
	private Widget w;
	private BaseVisualTheme visualTheme;

	private this(Widget w) {
		this.w = w;
		this.visualTheme = WidgetPainter.visualTheme;
	}

	/// Forwards to [Widget.Style]
	// through the [VisualTheme]
	public @property opDispatch(string name)() {
		typeof(__traits(getMember, Widget.Style.init, name)()) prop;
		w.useStyleProperties((scope Widget.Style props) {
		//visualTheme.useStyleProperties(w, (props) {
			prop = __traits(getMember, props, name);
		});
		return prop;
	}

	@property {
		// Layout helpers. Currently just forwarding since I haven't made up my mind on a better way.
		/** */ int paddingLeft() { return w.paddingLeft(); }
		/** */ int paddingRight() { return w.paddingRight(); }
		/** */ int paddingTop() { return w.paddingTop(); }
		/** */ int paddingBottom() { return w.paddingBottom(); }

		/** */ int marginLeft() { return w.marginLeft(); }
		/** */ int marginRight() { return w.marginRight(); }
		/** */ int marginTop() { return w.marginTop(); }
		/** */ int marginBottom() { return w.marginBottom(); }

		/** */ int maxHeight() { return w.maxHeight(); }
		/** */ int minHeight() { return w.minHeight(); }

		/** */ int maxWidth() { return w.maxWidth(); }
		/** */ int minWidth() { return w.minWidth(); }

		// Global helpers some of these are unstable.
		static:
		/** */ Color windowBackgroundColor() { return WidgetPainter.visualTheme.windowBackgroundColor(); }
		/** */ Color widgetBackgroundColor() { return WidgetPainter.visualTheme.widgetBackgroundColor(); }
		/** */ Color lightAccentColor() { return WidgetPainter.visualTheme.lightAccentColor(); }
		/** */ Color darkAccentColor() { return WidgetPainter.visualTheme.darkAccentColor(); }

		/** */ Color activeTabColor() { return lightAccentColor; }
		/** */ Color buttonColor() { return windowBackgroundColor; }
		/** */ Color depressedButtonColor() { return darkAccentColor; }
		/** */ Color hoveringColor() { return Color(228, 228, 228); }
		/** */ Color activeListXorColor() {
			auto c = WidgetPainter.visualTheme.selectionColor();
			return Color(c.r ^ 255, c.g ^ 255, c.b ^ 255, c.a);
		}
		/** */ Color progressBarColor() { return WidgetPainter.visualTheme.selectionColor(); }
		/** */ Color activeMenuItemColor() { return WidgetPainter.visualTheme.selectionColor(); }
	}



	/+

	private static auto extractStyleProperty(string name)(Widget w) {
		typeof(__traits(getMember, Widget.Style.init, name)()) prop;
		w.useStyleProperties((props) {
			prop = __traits(getMember, props, name);
		});
		return prop;
	}

	// FIXME: clear this upon a X server disconnect
	private static OperatingSystemFont[string] fontCache;

	T getProperty(T)(string name, lazy T default_) {
		if(visualTheme !is null) {
			auto str = visualTheme.getPropertyString(w, name);
			if(str is null)
				return default_;
			static if(is(T == Color))
				return Color.fromString(str);
			else static if(is(T == Measurement))
				return Measurement(cast(int) toInternal!int(str));
			else static if(is(T == WidgetBackground))
				return WidgetBackground.fromString(str);
			else static if(is(T == OperatingSystemFont)) {
				if(auto f = str in fontCache)
					return *f;
				else
					return fontCache[str] = new OperatingSystemFont(str);
			} else static if(is(T == FrameStyle)) {
				switch(str) {
					default:
						return FrameStyle.none;
					foreach(style; __traits(allMembers, FrameStyle))
					case style:
						return __traits(getMember, FrameStyle, style);
				}
			} else static assert(0);
		} else
			return default_;
	}

	static struct Measurement {
		int value;
		alias value this;
	}

	@property:

	int paddingLeft() { return getProperty("padding-left", Measurement(w.paddingLeft())); }
	int paddingRight() { return getProperty("padding-right", Measurement(w.paddingRight())); }
	int paddingTop() { return getProperty("padding-top", Measurement(w.paddingTop())); }
	int paddingBottom() { return getProperty("padding-bottom", Measurement(w.paddingBottom())); }

	int marginLeft() { return getProperty("margin-left", Measurement(w.marginLeft())); }
	int marginRight() { return getProperty("margin-right", Measurement(w.marginRight())); }
	int marginTop() { return getProperty("margin-top", Measurement(w.marginTop())); }
	int marginBottom() { return getProperty("margin-bottom", Measurement(w.marginBottom())); }

	int maxHeight() { return getProperty("max-height", Measurement(w.maxHeight())); }
	int minHeight() { return getProperty("min-height", Measurement(w.minHeight())); }

	int maxWidth() { return getProperty("max-width", Measurement(w.maxWidth())); }
	int minWidth() { return getProperty("min-width", Measurement(w.minWidth())); }


	WidgetBackground background() { return getProperty("background", extractStyleProperty!"background"(w)); }
	Color foregroundColor() { return getProperty("foreground-color", extractStyleProperty!"foregroundColor"(w)); }

	OperatingSystemFont font() { return getProperty("font", extractStyleProperty!"fontCached"(w)); }

	FrameStyle borderStyle() { return getProperty("border-style", extractStyleProperty!"borderStyle"(w)); }
	Color borderColor() { return getProperty("border-color", extractStyleProperty!"borderColor"(w)); }

	FrameStyle outlineStyle() { return getProperty("outline-style", extractStyleProperty!"outlineStyle"(w)); }
	Color outlineColor() { return getProperty("outline-color", extractStyleProperty!"outlineColor"(w)); }


	Color windowBackgroundColor() { return WidgetPainter.visualTheme.windowBackgroundColor(); }
	Color widgetBackgroundColor() { return WidgetPainter.visualTheme.widgetBackgroundColor(); }
	Color lightAccentColor() { return WidgetPainter.visualTheme.lightAccentColor(); }
	Color darkAccentColor() { return WidgetPainter.visualTheme.darkAccentColor(); }

	Color activeTabColor() { return lightAccentColor; }
	Color buttonColor() { return windowBackgroundColor; }
	Color depressedButtonColor() { return darkAccentColor; }
	Color hoveringColor() { return Color(228, 228, 228); }
	Color activeListXorColor() {
		auto c = WidgetPainter.visualTheme.selectionColor();
		return Color(c.r ^ 255, c.g ^ 255, c.b ^ 255, c.a);
	}
	Color progressBarColor() { return WidgetPainter.visualTheme.selectionColor(); }
	Color activeMenuItemColor() { return WidgetPainter.visualTheme.selectionColor(); }
	+/
}



// pragma(msg, __traits(classInstanceSize, Widget));

/*private*/ template EventString(E) {
	static if(is(typeof(E.EventString)))
		enum EventString = E.EventString;
	else
		enum EventString = E.mangleof; // FIXME fqn? or something more user friendly
}

/*private*/ template EventStringIdentifier(E) {
	string helper() {
		auto es = EventString!E;
		char[] id = new char[](es.length * 2);
		size_t idx;
		foreach(char ch; es) {
			id[idx++] = cast(char)('a' + (ch >> 4));
			id[idx++] = cast(char)('a' + (ch & 0x0f));
		}
		return cast(string) id;
	}

	enum EventStringIdentifier = helper();
}


template classStaticallyEmits(This, EventType) {
	static if(is(This Base == super))
		static if(is(Base : Widget))
			enum baseEmits = classStaticallyEmits!(Base, EventType);
		else
			enum baseEmits = false;
	else
		enum baseEmits = false;

	enum thisEmits = is(typeof(__traits(getMember, This, "emits_" ~ EventStringIdentifier!EventType)) == EventType[0]);

	enum classStaticallyEmits = thisEmits || baseEmits;
}

/++
	Nests an opengl capable window inside this window as a widget.

	You may also just want to create an additional [SimpleWindow] with
	[OpenGlOptions.yes] yourself.

	An OpenGL widget cannot have child widgets. It will throw if you try.
+/
static if(OpenGlEnabled)
class OpenGlWidget : Widget {
	SimpleWindow win;

	///
	this(Widget parent) {
		this.parentWindow = parent.parentWindow;

		SimpleWindow pwin = this.parentWindow.win;


		version(win32_widgets) {
			HWND phwnd;
			auto wtf = parent;
			while(wtf) {
				if(wtf.hwnd) {
					phwnd = wtf.hwnd;
					break;
				}
				wtf = wtf.parent;
			}
			// kinda a hack here just because the ctor below just needs a SimpleWindow wrapper....
			if(phwnd)
				pwin = new SimpleWindow(phwnd);
		}

		win = new SimpleWindow(640, 480, null, OpenGlOptions.yes, Resizability.automaticallyScaleIfPossible, WindowTypes.nestedChild, WindowFlags.normal, pwin);
		super(parent);

		windowsetup(win);
	}

	protected void windowsetup(SimpleWindow w) {
		/*
		win.onFocusChange = (bool getting) {
			if(getting)
				this.focus();
		};
		*/

		version(win32_widgets) {
			Widget.nativeMapping[win.hwnd] = this;
			this.originalWindowProcedure = cast(WNDPROC) SetWindowLongPtr(win.hwnd, GWL_WNDPROC, cast(size_t) &HookedWndProc);
		} else {
			win.setEventHandlers(
				(MouseEvent e) {
					Widget p = this;
					while(p ! is parentWindow) {
						e.x += p.x;
						e.y += p.y;
						p = p.parent;
					}
					parentWindow.dispatchMouseEvent(e);
				},
				(KeyEvent e) {
					//import std.stdio;
					//writefln("%x   %s", cast(uint) e.key, e.key);
					parentWindow.dispatchKeyEvent(e);
				},
				(dchar e) {
					parentWindow.dispatchCharEvent(e);
				},
			);
		}

	}

	override void paint(WidgetPainter painter) {
		win.redrawOpenGlSceneNow();
	}

	void redrawOpenGlScene(void delegate() dg) {
		win.redrawOpenGlScene = dg;
	}

	override void showing(bool s, bool recalc) {
		auto cur = hidden;
		win.hidden = !s;
		if(cur != s && s)
			redraw();
	}

	/// OpenGL widgets cannot have child widgets. Do not call this.
	/* @disable */ final override void addChild(Widget, int) {
		throw new Error("cannot add children to OpenGL widgets");
	}

	/// When an opengl widget is laid out, it will adjust the glViewport for you automatically.
	/// Keep in mind that events like mouse coordinates are still relative to your size.
	override void registerMovement() {
		//import std.stdio; writefln("%d %d %d %d", x,y,width,height);
		version(win32_widgets)
			auto pos = getChildPositionRelativeToParentHwnd(this);
		else
			auto pos = getChildPositionRelativeToParentOrigin(this);
		win.moveResize(pos[0], pos[1], width, height);

		win.setAsCurrentOpenGlContext();
		sendResizeEvent();
	}

	//void delegate() drawFrame;
}

version(custom_widgets)
	private alias ListWidgetBase = ScrollableWidget;
else
	private alias ListWidgetBase = Widget;

/++
	A list widget contains a list of strings that the user can examine and select.


	In the future, items in the list may be possible to be more than just strings.
+/
class ListWidget : ListWidgetBase {
	/// Sends a change event when the selection changes, but the data is not attached to the event. You must instead loop the options to see if they are selected.
	mixin Emits!(ChangeEvent!void);

	static struct Option {
		string label;
		bool selected;
	}

	/++
		Sets the current selection to the `y`th item in the list. Will emit [ChangeEvent] when complete.
	+/
	void setSelection(int y) {
		if(!multiSelect)
			foreach(ref opt; options)
				opt.selected = false;
		if(y >= 0 && y < options.length)
			options[y].selected = !options[y].selected;

		this.emit!(ChangeEvent!void)(delegate {});

		version(custom_widgets)
			redraw();
	}

	version(custom_widgets)
	override void defaultEventHandler_click(ClickEvent event) {
		this.focus();
		auto y = (event.clientY - 4) / Window.lineHeight;
		if(y >= 0 && y < options.length) {
			setSelection(y);
		}
		super.defaultEventHandler_click(event);
	}

	this(Widget parent) {
		tabStop = false;
		super(parent);
		version(win32_widgets)
			createWin32Window(this, WC_LISTBOX, "", 
				0|WS_CHILD|WS_VISIBLE|LBS_NOTIFY, 0);
	}

	version(win32_widgets)
	override void handleWmCommand(ushort code, ushort id) {
		switch(code) {
			case LBN_SELCHANGE:
				auto sel = SendMessageW(hwnd, LB_GETCURSEL, 0, 0);
				setSelection(cast(int) sel);
			break;
			default:
		}
	}


	version(custom_widgets)
	override void paintFrameAndBackground(WidgetPainter painter) {
		draw3dFrame(this, painter, FrameStyle.sunk, Color.white);
	}

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		auto cs = getComputedStyle();
		auto pos = Point(4, 4);
		foreach(idx, option; options) {
			painter.fillColor = Color.white;
			painter.outlineColor = Color.white;
			painter.drawRectangle(pos, width - 8, Window.lineHeight);
			painter.outlineColor = cs.foregroundColor;
			painter.drawText(pos, option.label);
			if(option.selected) {
				painter.rasterOp = RasterOp.xor;
				painter.outlineColor = Color.white;
				painter.fillColor = cs.activeListXorColor;
				painter.drawRectangle(pos, width - 8, Window.lineHeight);
				painter.rasterOp = RasterOp.normal;
			}
			pos.y += Window.lineHeight;
		}
	}

	static class Style : Widget.Style {
		override WidgetBackground background() {
			return WidgetBackground(WidgetPainter.visualTheme.widgetBackgroundColor);
		}
	}
	mixin OverrideStyle!Style;
	//mixin Padding!q{2};

	void addOption(string text) {
		options ~= Option(text);
		version(win32_widgets) {
			WCharzBuffer buffer = WCharzBuffer(text);
			SendMessageW(hwnd, LB_ADDSTRING, 0, cast(LPARAM) buffer.ptr);
		}
		version(custom_widgets) {
			setContentSize(width, cast(int) (options.length * Window.lineHeight));
			redraw();
		}
	}

	void clear() {
		options = null;
		version(win32_widgets) {
			while(SendMessageW(hwnd, LB_DELETESTRING, 0, 0) > 0)
				{}

		} else version(custom_widgets) {
			redraw();
		}
	}

	Option[] options;
	version(win32_widgets)
		enum multiSelect = false; /// not implemented yet
	else
		bool multiSelect;

	override int heightStretchiness() { return 6; }
}



/// For [ScrollableWidget], determines when to show the scroll bar to the user.
enum ScrollBarShowPolicy {
	automatic, /// automatically show the scroll bar if it is necessary
	never, /// never show the scroll bar (scrolling must be done programmatically)
	always /// always show the scroll bar, even if it is disabled
}

/++
	A widget that tries (with, at best, limited success) to offer scrolling that is transparent to the inner.

	It isn't very good and may be removed. Try [ScrollMessageWidget] instead for new code.

+/
// FIXME ScrollBarShowPolicy
// FIXME: use the ScrollMessageWidget in here now that it exists
class ScrollableWidget : Widget {
	// FIXME: make line size configurable
	// FIXME: add keyboard controls
	version(win32_widgets) {
		override int hookedWndProc(UINT msg, WPARAM wParam, LPARAM lParam) {
			if(msg == WM_VSCROLL || msg == WM_HSCROLL) {
				auto pos = HIWORD(wParam);
				auto m = LOWORD(wParam);

				// FIXME: I can reintroduce the
				// scroll bars now by using this
				// in the top-level window handler
				// to forward comamnds
				auto scrollbarHwnd = lParam;
				switch(m) {
					case SB_BOTTOM:
						if(msg == WM_HSCROLL)
							horizontalScrollTo(contentWidth_);
						else
							verticalScrollTo(contentHeight_);
					break;
					case SB_TOP:
						if(msg == WM_HSCROLL)
							horizontalScrollTo(0);
						else
							verticalScrollTo(0);
					break;
					case SB_ENDSCROLL:
						// idk
					break;
					case SB_LINEDOWN:
						if(msg == WM_HSCROLL)
							horizontalScroll(16);
						else
							verticalScroll(16);
					break;
					case SB_LINEUP:
						if(msg == WM_HSCROLL)
							horizontalScroll(-16);
						else
							verticalScroll(-16);
					break;
					case SB_PAGEDOWN:
						if(msg == WM_HSCROLL)
							horizontalScroll(100);
						else
							verticalScroll(100);
					break;
					case SB_PAGEUP:
						if(msg == WM_HSCROLL)
							horizontalScroll(-100);
						else
							verticalScroll(-100);
					break;
					case SB_THUMBPOSITION:
					case SB_THUMBTRACK:
						if(msg == WM_HSCROLL)
							horizontalScrollTo(pos);
						else
							verticalScrollTo(pos);

						if(m == SB_THUMBTRACK) {
							// the event loop doesn't seem to carry on with a requested redraw..
							// so we request it to get our dirty bit set...
							redraw();
							// then we need to immediately actually redraw it too for instant feedback to user
							actualRedraw();
						}
					break;
					default:
				}
			}
			return 0;
		}
	}
	///
	this(Widget parent) {
		this.parentWindow = parent.parentWindow;

		version(win32_widgets) {
			static bool classRegistered = false;
			if(!classRegistered) {
				HINSTANCE hInstance = cast(HINSTANCE) GetModuleHandle(null);
				WNDCLASSEX wc;
				wc.cbSize = wc.sizeof;
				wc.hInstance = hInstance;
				wc.lpfnWndProc = &DefWindowProc;
				wc.lpszClassName = "arsd_minigui_ScrollableWidget"w.ptr;
				if(!RegisterClassExW(&wc))
					throw new Exception("RegisterClass ");// ~ to!string(GetLastError()));
				classRegistered = true;
			}

			createWin32Window(this, "arsd_minigui_ScrollableWidget"w, "", 
				0|WS_CHILD|WS_VISIBLE|WS_HSCROLL|WS_VSCROLL, 0);
			super(parent);
		} else version(custom_widgets) {
			outerContainer = new ScrollableContainerWidget(this, parent);
			super(outerContainer);
		} else static assert(0);
	}

	version(custom_widgets)
		ScrollableContainerWidget outerContainer;

	override void defaultEventHandler_click(ClickEvent event) {
		if(event.button == MouseButton.wheelUp)
			verticalScroll(-16);
		if(event.button == MouseButton.wheelDown)
			verticalScroll(16);
		super.defaultEventHandler_click(event);
	}

	override void defaultEventHandler_keydown(KeyDownEvent event) {
		switch(event.key) {
			case Key.Left:
				horizontalScroll(-16);
			break;
			case Key.Right:
				horizontalScroll(16);
			break;
			case Key.Up:
				verticalScroll(-16);
			break;
			case Key.Down:
				verticalScroll(16);
			break;
			case Key.Home:
				verticalScrollTo(0);
			break;
			case Key.End:
				verticalScrollTo(contentHeight);
			break;
			case Key.PageUp:
				verticalScroll(-160);
			break;
			case Key.PageDown:
				verticalScroll(160);
			break;
			default:
		}
		super.defaultEventHandler_keydown(event);
	}


	version(win32_widgets)
	override void recomputeChildLayout() {
		super.recomputeChildLayout();
		SCROLLINFO info;
		info.cbSize = info.sizeof;
		info.nPage = viewportHeight;
		info.fMask = SIF_PAGE | SIF_RANGE;
		info.nMin = 0;
		info.nMax = contentHeight_;
		SetScrollInfo(hwnd, SB_VERT, &info, true);

		info.cbSize = info.sizeof;
		info.nPage = viewportWidth;
		info.fMask = SIF_PAGE | SIF_RANGE;
		info.nMin = 0;
		info.nMax = contentWidth_;
		SetScrollInfo(hwnd, SB_HORZ, &info, true);
	}



	/*
		Scrolling
		------------

		You are assigned a width and a height by the layout engine, which
		is your viewport box. However, you may draw more than that by setting
		a contentWidth and contentHeight.

		If these can be contained by the viewport, no scrollbar is displayed.
		If they cannot fit though, it will automatically show scroll as necessary.

		If contentWidth == 0, no horizontal scrolling is performed. If contentHeight
		is zero, no vertical scrolling is performed.

		If scrolling is necessary, the lib will automatically work with the bars.
		When you redraw, the origin and clipping info in the painter is set so if
		you just draw everything, it will work, but you can be more efficient by checking
		the viewportWidth, viewportHeight, and scrollOrigin members.
	*/

	///
	final @property int viewportWidth() {
		return width - (showingVerticalScroll ? 16 : 0);
	}
	///
	final @property int viewportHeight() {
		return height - (showingHorizontalScroll ? 16 : 0);
	}

	// FIXME property
	Point scrollOrigin_;

	///
	final const(Point) scrollOrigin() {
		return scrollOrigin_;
	}

	// the user sets these two
	private int contentWidth_ = 0;
	private int contentHeight_ = 0;

	///
	int contentWidth() { return contentWidth_; }
	///
	int contentHeight() { return contentHeight_; }

	///
	void setContentSize(int width, int height) {
		contentWidth_ = width;
		contentHeight_ = height;

		version(custom_widgets) {
			if(showingVerticalScroll || showingHorizontalScroll) {
				outerContainer.recomputeChildLayout();
			}

			if(showingVerticalScroll())
				outerContainer.verticalScrollBar.redraw();
			if(showingHorizontalScroll())
				outerContainer.horizontalScrollBar.redraw();
		} else version(win32_widgets) {
			recomputeChildLayout();
		} else static assert(0);
	}

	///
	void verticalScroll(int delta) {
		verticalScrollTo(scrollOrigin.y + delta);
	}
	///
	void verticalScrollTo(int pos) {
		scrollOrigin_.y = pos;
		if(pos == int.max || (scrollOrigin_.y + viewportHeight > contentHeight))
			scrollOrigin_.y = contentHeight - viewportHeight;

		if(scrollOrigin_.y < 0)
			scrollOrigin_.y = 0;

		version(win32_widgets) {
			SCROLLINFO info;
			info.cbSize = info.sizeof;
			info.fMask = SIF_POS;
			info.nPos = scrollOrigin_.y;
			SetScrollInfo(hwnd, SB_VERT, &info, true);
		} else version(custom_widgets) {
			outerContainer.verticalScrollBar.setPosition(scrollOrigin_.y);
		} else static assert(0);

		redraw();
	}

	///
	void horizontalScroll(int delta) {
		horizontalScrollTo(scrollOrigin.x + delta);
	}
	///
	void horizontalScrollTo(int pos) {
		scrollOrigin_.x = pos;
		if(pos == int.max || (scrollOrigin_.x + viewportWidth > contentWidth))
			scrollOrigin_.x = contentWidth - viewportWidth;

		if(scrollOrigin_.x < 0)
			scrollOrigin_.x = 0;

		version(win32_widgets) {
			SCROLLINFO info;
			info.cbSize = info.sizeof;
			info.fMask = SIF_POS;
			info.nPos = scrollOrigin_.x;
			SetScrollInfo(hwnd, SB_HORZ, &info, true);
		} else version(custom_widgets) {
			outerContainer.horizontalScrollBar.setPosition(scrollOrigin_.x);
		} else static assert(0);

		redraw();
	}
	///
	void scrollTo(Point p) {
		verticalScrollTo(p.y);
		horizontalScrollTo(p.x);
	}

	///
	void ensureVisibleInScroll(Point p) {
		auto rect = viewportRectangle();
		if(rect.contains(p))
			return;
		if(p.x < rect.left)
			horizontalScroll(p.x - rect.left);
		else if(p.x > rect.right)
			horizontalScroll(p.x - rect.right);

		if(p.y < rect.top)
			verticalScroll(p.y - rect.top);
		else if(p.y > rect.bottom)
			verticalScroll(p.y - rect.bottom);
	}

	///
	void ensureVisibleInScroll(Rectangle rect) {
		ensureVisibleInScroll(rect.upperLeft);
		ensureVisibleInScroll(rect.lowerRight);
	}

	///
	Rectangle viewportRectangle() {
		return Rectangle(scrollOrigin, Size(viewportWidth, viewportHeight));
	}

	///
	bool showingHorizontalScroll() {
		return contentWidth > width;
	}
	///
	bool showingVerticalScroll() {
		return contentHeight > height;
	}

	/// This is called before the ordinary paint delegate,
	/// giving you a chance to draw the window frame, etc,
	/// before the scroll clip takes effect
	void paintFrameAndBackground(WidgetPainter painter) {
		version(win32_widgets) {
			auto b = SelectObject(painter.impl.hdc, GetSysColorBrush(COLOR_3DFACE));
			auto p = SelectObject(painter.impl.hdc, GetStockObject(NULL_PEN));
			// since the pen is null, to fill the whole space, we need the +1 on both.
			gdi.Rectangle(painter.impl.hdc, 0, 0, this.width + 1, this.height + 1);
			SelectObject(painter.impl.hdc, p);
			SelectObject(painter.impl.hdc, b);
		}

	}

	// make space for the scroll bar, and that's it.
	final override int paddingRight() { return 16; }
	final override int paddingBottom() { return 16; }

	/*
		END SCROLLING
	*/

	override WidgetPainter draw() {
		int x = this.x, y = this.y;
		auto parent = this.parent;
		while(parent) {
			x += parent.x;
			y += parent.y;
			parent = parent.parent;
		}

		//version(win32_widgets) {
			//auto painter = simpleWindowWrappingHwnd ? simpleWindowWrappingHwnd.draw() : parentWindow.win.draw();
		//} else {
			auto painter = parentWindow.win.draw();
		//}
		painter.originX = x;
		painter.originY = y;

		painter.originX = painter.originX - scrollOrigin.x;
		painter.originY = painter.originY - scrollOrigin.y;
		painter.setClipRectangle(scrollOrigin, viewportWidth(), viewportHeight());

		return WidgetPainter(painter, this);
	}

	override protected void privatePaint(WidgetPainter painter, int lox, int loy, bool force = false) {
		if(hidden)
			return;

		//version(win32_widgets)
			//painter = simpleWindowWrappingHwnd ? simpleWindowWrappingHwnd.draw() : parentWindow.win.draw();

		painter.originX = lox + x;
		painter.originY = loy + y;

		bool actuallyPainted = false;

		if(force || redrawRequested) {
			painter.setClipRectangle(Point(0, 0), width, height);
			paintFrameAndBackground(painter);
		}

		painter.originX = painter.originX - scrollOrigin.x;
		painter.originY = painter.originY - scrollOrigin.y;
		if(force || redrawRequested) {
			painter.setClipRectangle(scrollOrigin + Point(2, 2) /* border */, width - 4, height - 4);

			//erase(painter); // we paintFrameAndBackground above so no need
			if(painter.visualTheme)
				painter.visualTheme.doPaint(this, painter);
			else
				paint(painter);

			actuallyPainted = true;
			redrawRequested = false;
		}
		foreach(child; children) {
			if(cast(FixedPosition) child)
				child.privatePaint(painter, painter.originX + scrollOrigin.x, painter.originY + scrollOrigin.y, actuallyPainted);
			else
				child.privatePaint(painter, painter.originX, painter.originY, actuallyPainted);
		}
	}
}

version(custom_widgets)
private class ScrollableContainerWidget : Widget {

	ScrollableWidget sw;

	VerticalScrollbar verticalScrollBar;
	HorizontalScrollbar horizontalScrollBar;

	this(ScrollableWidget sw, Widget parent) {
		this.sw = sw;

		this.tabStop = false;

		horizontalScrollBar = new HorizontalScrollbar(this);
		verticalScrollBar = new VerticalScrollbar(this);

		horizontalScrollBar.showing_ = false;
		verticalScrollBar.showing_ = false;

		horizontalScrollBar.addEventListener("scrolltonextline", {
			horizontalScrollBar.setPosition(horizontalScrollBar.position + 1);
			sw.horizontalScrollTo(horizontalScrollBar.position);
		});
		horizontalScrollBar.addEventListener("scrolltopreviousline", {
			horizontalScrollBar.setPosition(horizontalScrollBar.position - 1);
			sw.horizontalScrollTo(horizontalScrollBar.position);
		});
		verticalScrollBar.addEventListener("scrolltonextline", {
			verticalScrollBar.setPosition(verticalScrollBar.position + 1);
			sw.verticalScrollTo(verticalScrollBar.position);
		});
		verticalScrollBar.addEventListener("scrolltopreviousline", {
			verticalScrollBar.setPosition(verticalScrollBar.position - 1);
			sw.verticalScrollTo(verticalScrollBar.position);
		});
		horizontalScrollBar.addEventListener("scrolltonextpage", {
			horizontalScrollBar.setPosition(horizontalScrollBar.position + horizontalScrollBar.step_);
			sw.horizontalScrollTo(horizontalScrollBar.position);
		});
		horizontalScrollBar.addEventListener("scrolltopreviouspage", {
			horizontalScrollBar.setPosition(horizontalScrollBar.position - horizontalScrollBar.step_);
			sw.horizontalScrollTo(horizontalScrollBar.position);
		});
		verticalScrollBar.addEventListener("scrolltonextpage", {
			verticalScrollBar.setPosition(verticalScrollBar.position + verticalScrollBar.step_);
			sw.verticalScrollTo(verticalScrollBar.position);
		});
		verticalScrollBar.addEventListener("scrolltopreviouspage", {
			verticalScrollBar.setPosition(verticalScrollBar.position - verticalScrollBar.step_);
			sw.verticalScrollTo(verticalScrollBar.position);
		});
		horizontalScrollBar.addEventListener("scrolltoposition", (Event event) {
			horizontalScrollBar.setPosition(event.intValue);
			sw.horizontalScrollTo(horizontalScrollBar.position);
		});
		verticalScrollBar.addEventListener("scrolltoposition", (Event event) {
			verticalScrollBar.setPosition(event.intValue);
			sw.verticalScrollTo(verticalScrollBar.position);
		});
		horizontalScrollBar.addEventListener("scrolltrack", (Event event) {
			horizontalScrollBar.setPosition(event.intValue);
			sw.horizontalScrollTo(horizontalScrollBar.position);
		});
		verticalScrollBar.addEventListener("scrolltrack", (Event event) {
			verticalScrollBar.setPosition(event.intValue);
		});

		super(parent);
	}

	// this is supposed to be basically invisible...
	override int minWidth() { return sw.minWidth; }
	override int minHeight() { return sw.minHeight; }
	override int maxWidth() { return sw.maxWidth; }
	override int maxHeight() { return sw.maxHeight; }
	override int widthStretchiness() { return sw.widthStretchiness; }
	override int heightStretchiness() { return sw.heightStretchiness; }
	override int marginLeft() { return sw.marginLeft; }
	override int marginRight() { return sw.marginRight; }
	override int marginTop() { return sw.marginTop; }
	override int marginBottom() { return sw.marginBottom; }
	override int paddingLeft() { return sw.paddingLeft; }
	override int paddingRight() { return sw.paddingRight; }
	override int paddingTop() { return sw.paddingTop; }
	override int paddingBottom() { return sw.paddingBottom; }
	override void focus() { sw.focus(); }


	override void recomputeChildLayout() {
		if(sw is null) return;

		bool both = sw.showingVerticalScroll && sw.showingHorizontalScroll;
		if(horizontalScrollBar && verticalScrollBar) {
			horizontalScrollBar.width = this.width - (both ? verticalScrollBar.minWidth() : 0);
			horizontalScrollBar.height = horizontalScrollBar.minHeight();
			horizontalScrollBar.x = 0;
			horizontalScrollBar.y = this.height - horizontalScrollBar.minHeight();

			verticalScrollBar.width = verticalScrollBar.minWidth();
			verticalScrollBar.height = this.height - (both ? horizontalScrollBar.minHeight() : 0) - 2 - 2;
			verticalScrollBar.x = this.width - verticalScrollBar.minWidth();
			verticalScrollBar.y = 0 + 2;

			sw.x = 0;
			sw.y = 0;
			sw.width = this.width - (verticalScrollBar.showing ? verticalScrollBar.width : 0);
			sw.height = this.height - (horizontalScrollBar.showing ? horizontalScrollBar.height : 0);

			if(sw.contentWidth_ <= this.width)
				sw.scrollOrigin_.x = 0;
			if(sw.contentHeight_ <= this.height)
				sw.scrollOrigin_.y = 0;

			horizontalScrollBar.recomputeChildLayout();
			verticalScrollBar.recomputeChildLayout();
			sw.recomputeChildLayout();
		}

		if(sw.contentWidth_ <= this.width)
			sw.scrollOrigin_.x = 0;
		if(sw.contentHeight_ <= this.height)
			sw.scrollOrigin_.y = 0;

		if(sw.showingHorizontalScroll())
			horizontalScrollBar.showing = true;
		else
			horizontalScrollBar.showing = false;
		if(sw.showingVerticalScroll())
			verticalScrollBar.showing = true;
		else
			verticalScrollBar.showing = false;


		verticalScrollBar.setViewableArea(sw.viewportHeight());
		verticalScrollBar.setMax(sw.contentHeight);
		verticalScrollBar.setPosition(sw.scrollOrigin.y);

		horizontalScrollBar.setViewableArea(sw.viewportWidth());
		horizontalScrollBar.setMax(sw.contentWidth);
		horizontalScrollBar.setPosition(sw.scrollOrigin.x);
	}
}

/*
class ScrollableClientWidget : Widget {
	this(Widget parent) {
		super(parent);
	}
	override void paint(WidgetPainter p) {
		parent.paint(p);
	}
}
*/

/++
	A slider, also known as a trackbar control, is commonly used in applications like volume controls where you want the user to select a value between a min and a max without needing a specific value or otherwise precise input.
+/
abstract class Slider : Widget {
	this(int min, int max, int step, Widget parent) {
		min_ = min;
		max_ = max;
		step_ = step;
		page_ = step;
		super(parent);
	}

	private int min_;
	private int max_;
	private int step_;
	private int position_;
	private int page_;

	// selection start and selection end
	// tics
	// tooltip?
	// some way to see and just type the value
	// win32 buddy controls are labels

	///
	void setMin(int a) {
		min_ = a;
		version(custom_widgets)
			redraw();
		version(win32_widgets)
			SendMessage(hwnd, TBM_SETRANGEMIN, true, a);
	}
	///
	int min() {
		return min_;
	}
	///
	void setMax(int a) {
		max_ = a;
		version(custom_widgets)
			redraw();
		version(win32_widgets)
			SendMessage(hwnd, TBM_SETRANGEMAX, true, a);
	}
	///
	int max() {
		return max_;
	}
	///
	void setPosition(int a) {
		if(a > max)
			a = max;
		if(a < min)
			a = min;
		position_ = a;
		version(custom_widgets)
			setPositionCustom(a);

		version(win32_widgets)
			setPositionWindows(a);
	}
	version(win32_widgets) {
		protected abstract void setPositionWindows(int a);
	}

	protected abstract int win32direction();

	///
	int position() {
		return position_;
	}
	///
	void setStep(int a) {
		step_ = a;
		version(win32_widgets)
			SendMessage(hwnd, TBM_SETLINESIZE, 0, a);
	}
	///
	int step() {
		return step_;
	}
	///
	void setPageSize(int a) {
		page_ = a;
		version(win32_widgets)
			SendMessage(hwnd, TBM_SETPAGESIZE, 0, a);
	}
	///
	int pageSize() {
		return page_;
	}

	private void notify() {
		auto event = new ChangeEvent!int(this, &this.position);
		event.dispatch();
	}

	version(win32_widgets)
	void win32Setup(int style) {
		createWin32Window(this, TRACKBAR_CLASS, "", 
			0|WS_CHILD|WS_VISIBLE|style|TBS_TOOLTIPS, 0);

		// the trackbar sends the same messages as scroll, which
		// our other layer sends as these... just gonna translate
		// here
		this.addDirectEventListener("scrolltoposition", (Event event) {
			event.stopPropagation();
			this.setPosition(this.win32direction > 0 ? event.intValue : max - event.intValue);
			notify();
		});
		this.addDirectEventListener("scrolltonextline", (Event event) {
			event.stopPropagation();
			this.setPosition(this.position + this.step_ * this.win32direction);
			notify();
		});
		this.addDirectEventListener("scrolltopreviousline", (Event event) {
			event.stopPropagation();
			this.setPosition(this.position - this.step_ * this.win32direction);
			notify();
		});
		this.addDirectEventListener("scrolltonextpage", (Event event) {
			event.stopPropagation();
			this.setPosition(this.position + this.page_ * this.win32direction);
			notify();
		});
		this.addDirectEventListener("scrolltopreviouspage", (Event event) {
			event.stopPropagation();
			this.setPosition(this.position - this.page_ * this.win32direction);
			notify();
		});

		setMin(min_);
		setMax(max_);
		setStep(step_);
		setPageSize(page_);
	}

	version(custom_widgets) {
		protected MouseTrackingWidget thumb;

		protected abstract void setPositionCustom(int a);

		override void defaultEventHandler_keydown(KeyDownEvent event) {
			switch(event.key) {
				case Key.Up:
				case Key.Right:
					setPosition(position() - step() * win32direction);
					changed();
				break;
				case Key.Down:
				case Key.Left:
					setPosition(position() + step() * win32direction);
					changed();
				break;
				case Key.Home:
					setPosition(win32direction > 0 ? min() : max());
					changed();
				break;
				case Key.End:
					setPosition(win32direction > 0 ? max() : min());
					changed();
				break;
				case Key.PageUp:
					setPosition(position() - pageSize() * win32direction);
					changed();
				break;
				case Key.PageDown:
					setPosition(position() + pageSize() * win32direction);
					changed();
				break;
				default:
			}
			super.defaultEventHandler_keydown(event);
		}

		protected void changed() {
			auto ev = new ChangeEvent!int(this, &position);
			ev.dispatch();
		}
	}
}

/++

+/
class VerticalSlider : Slider {
	this(int min, int max, int step, Widget parent) {
		version(custom_widgets)
			initialize();

		super(min, max, step, parent);

		version(win32_widgets)
			win32Setup(TBS_VERT | 0x0200 /* TBS_REVERSED */);
	}

	protected override int win32direction() {
		return -1;
	}

	version(win32_widgets)
	protected override void setPositionWindows(int a) {
		// the windows thing makes the top 0 and i don't like that.
		SendMessage(hwnd, TBM_SETPOS, true, max - a);
	}

	version(custom_widgets)
	private void initialize() {
		thumb = new MouseTrackingWidget(MouseTrackingWidget.Orientation.vertical, this);

		thumb.tabStop = false;

		thumb.thumbWidth = width;
		thumb.thumbHeight = 16;

		thumb.addEventListener(EventType.change, () {
			auto sx = thumb.positionY * max() / (thumb.height - 16);
			sx = max - sx;
			//informProgramThatUserChangedPosition(sx);

			position_ = sx;

			changed();
		});
	}

	version(custom_widgets)
	override void recomputeChildLayout() {
		thumb.thumbWidth = this.width;
		super.recomputeChildLayout();
		setPositionCustom(position_);
	}

	version(custom_widgets)
	protected override void setPositionCustom(int a) {
		if(max())
			thumb.positionY = (max - a) * (thumb.height - 16) / max();
		redraw();
	}
}

/++

+/
class HorizontalSlider : Slider {
	this(int min, int max, int step, Widget parent) {
		version(custom_widgets)
			initialize();

		super(min, max, step, parent);

		version(win32_widgets)
			win32Setup(TBS_HORZ);
	}

	version(win32_widgets)
	protected override void setPositionWindows(int a) {
		SendMessage(hwnd, TBM_SETPOS, true, a);
	}

	protected override int win32direction() {
		return 1;
	}

	version(custom_widgets)
	private void initialize() {
		thumb = new MouseTrackingWidget(MouseTrackingWidget.Orientation.horizontal, this);

		thumb.tabStop = false;

		thumb.thumbWidth = 16;
		thumb.thumbHeight = height;

		thumb.addEventListener(EventType.change, () {
			auto sx = thumb.positionX * max() / (thumb.width - 16);
			//informProgramThatUserChangedPosition(sx);

			position_ = sx;

			changed();
		});
	}

	version(custom_widgets)
	override void recomputeChildLayout() {
		thumb.thumbHeight = this.height;
		super.recomputeChildLayout();
		setPositionCustom(position_);
	}

	version(custom_widgets)
	protected override void setPositionCustom(int a) {
		if(max())
			thumb.positionX = a * (thumb.width - 16) / max();
		redraw();
	}
}


///
abstract class ScrollbarBase : Widget {
	///
	this(Widget parent) {
		super(parent);
		tabStop = false;
	}

	private int viewableArea_;
	private int max_;
	private int step_ = 16;
	private int position_;

	///
	bool atEnd() {
		return position_ + viewableArea_ >= max_;
	}

	///
	bool atStart() {
		return position_ == 0;
	}

	///
	void setViewableArea(int a) {
		viewableArea_ = a;
		version(custom_widgets)
			redraw();
	}
	///
	void setMax(int a) {
		max_ = a;
		version(custom_widgets)
			redraw();
	}
	///
	int max() {
		return max_;
	}
	///
	void setPosition(int a) {
		if(a == int.max)
			a = max;
		position_ = max ? a : 0;
		if(position_ + viewableArea_ > max)
			position_ = max - viewableArea_;
		if(position_ < 0)
			position_ = 0;
		version(custom_widgets)
			redraw();
	}
	///
	int position() {
		return position_;
	}
	///
	void setStep(int a) {
		step_ = a;
	}
	///
	int step() {
		return step_;
	}

	// FIXME: remove this.... maybe
	/+
	protected void informProgramThatUserChangedPosition(int n) {
		position_ = n;
		auto evt = new Event(EventType.change, this);
		evt.intValue = n;
		evt.dispatch();
	}
	+/

	version(custom_widgets) {
		abstract protected int getBarDim();
		int thumbSize() {
			if(viewableArea_ >= max_)
				return getBarDim();

			int res;
			if(max_) {
				res = getBarDim() * viewableArea_ / max_;
			}
			if(res < 6)
				res = 6;

			return res;
		}

		int thumbPosition() {
			/*
				viewableArea_ is the viewport height/width
				position_ is where we are
			*/
			if(max_) {
				if(position_ + viewableArea_ >= max_)
					return getBarDim - thumbSize;
				return getBarDim * position_ / max_;
			}
			return 0;
		}
	}
}

//public import mgt;

/++
	A mouse tracking widget is one that follows the mouse when dragged inside it.

	Concrete subclasses may include a scrollbar thumb and a volume control.
+/
//version(custom_widgets)
class MouseTrackingWidget : Widget {

	///
	int positionX() { return positionX_; }
	///
	int positionY() { return positionY_; }

	///
	void positionX(int p) { positionX_ = p; }
	///
	void positionY(int p) { positionY_ = p; }

	private int positionX_;
	private int positionY_;

	///
	enum Orientation {
		horizontal, ///
		vertical, ///
		twoDimensional, ///
	}

	private int thumbWidth_;
	private int thumbHeight_;

	///
	int thumbWidth() { return thumbWidth_; }
	///
	int thumbHeight() { return thumbHeight_; }
	///
	int thumbWidth(int a) { return thumbWidth_ = a; }
	///
	int thumbHeight(int a) { return thumbHeight_ = a; }

	private bool dragging;
	private bool hovering;
	private int startMouseX, startMouseY;

	///
	this(Orientation orientation, Widget parent) {
		super(parent);

		//assert(parentWindow !is null);

		addEventListener((MouseDownEvent event) {
			if(event.clientX >= positionX && event.clientX < positionX + thumbWidth && event.clientY >= positionY && event.clientY < positionY + thumbHeight) {
				dragging = true;
				startMouseX = event.clientX - positionX;
				startMouseY = event.clientY - positionY;
				parentWindow.captureMouse(this);
			} else {
				if(orientation == Orientation.horizontal || orientation == Orientation.twoDimensional)
					positionX = event.clientX - thumbWidth / 2;
				if(orientation == Orientation.vertical || orientation == Orientation.twoDimensional)
					positionY = event.clientY - thumbHeight / 2;

				if(positionX + thumbWidth > this.width)
					positionX = this.width - thumbWidth;
				if(positionY + thumbHeight > this.height)
					positionY = this.height - thumbHeight;

				if(positionX < 0)
					positionX = 0;
				if(positionY < 0)
					positionY = 0;


				// this.emit!(ChangeEvent!void)();
				auto evt = new Event(EventType.change, this);
				evt.sendDirectly();

				redraw();

			}
		});

		addEventListener(EventType.mouseup, (Event event) {
			dragging = false;
			parentWindow.releaseMouseCapture();
		});

		addEventListener(EventType.mouseout, (Event event) {
			if(!hovering)
				return;
			hovering = false;
			redraw();
		});

		int lpx, lpy;

		addEventListener((MouseMoveEvent event) {
			auto oh = hovering;
			if(event.clientX >= positionX && event.clientX < positionX + thumbWidth && event.clientY >= positionY && event.clientY < positionY + thumbHeight) {
				hovering = true;
			} else {
				hovering = false;
			}
			if(!dragging) {
				if(hovering != oh)
					redraw();
				return;
			}

			if(orientation == Orientation.horizontal || orientation == Orientation.twoDimensional)
				positionX = event.clientX - startMouseX; // FIXME: click could be in the middle of it
			if(orientation == Orientation.vertical || orientation == Orientation.twoDimensional)
				positionY = event.clientY - startMouseY;

			if(positionX + thumbWidth > this.width)
				positionX = this.width - thumbWidth;
			if(positionY + thumbHeight > this.height)
				positionY = this.height - thumbHeight;

			if(positionX < 0)
				positionX = 0;
			if(positionY < 0)
				positionY = 0;

			if(positionX != lpx || positionY != lpy) {
				auto evt = new Event(EventType.change, this);
				evt.sendDirectly();

				lpx = positionX;
				lpy = positionY;
			}

			redraw();
		});
	}

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		auto cs = getComputedStyle();
		auto c = darken(cs.windowBackgroundColor, 0.2);
		painter.outlineColor = c;
		painter.fillColor = c;
		painter.drawRectangle(Point(0, 0), this.width, this.height);

		auto color = hovering ? cs.hoveringColor : cs.windowBackgroundColor;
		draw3dFrame(positionX, positionY, thumbWidth, thumbHeight, painter, FrameStyle.risen, color);
	}
}

//version(custom_widgets)
//private
class HorizontalScrollbar : ScrollbarBase {

	version(custom_widgets) {
		private MouseTrackingWidget thumb;

		override int getBarDim() {
			return thumb.width;
		}
	}

	override void setViewableArea(int a) {
		super.setViewableArea(a);

		version(win32_widgets) {
			SCROLLINFO info;
			info.cbSize = info.sizeof;
			info.nPage = a + 1;
			info.fMask = SIF_PAGE;
			SetScrollInfo(hwnd, SB_CTL, &info, true);
		} else version(custom_widgets) {
			thumb.positionX = thumbPosition;
			thumb.thumbWidth = thumbSize;
			thumb.redraw();
		} else static assert(0);

	}

	override void setMax(int a) {
		super.setMax(a);
		version(win32_widgets) {
			SCROLLINFO info;
			info.cbSize = info.sizeof;
			info.nMin = 0;
			info.nMax = max;
			info.fMask = SIF_RANGE;
			SetScrollInfo(hwnd, SB_CTL, &info, true);
		} else version(custom_widgets) {
			thumb.positionX = thumbPosition;
			thumb.thumbWidth = thumbSize;
			thumb.redraw();
		}
	}

	override void setPosition(int a) {
		super.setPosition(a);
		version(win32_widgets) {
			SCROLLINFO info;
			info.cbSize = info.sizeof;
			info.fMask = SIF_POS;
			info.nPos = position;
			SetScrollInfo(hwnd, SB_CTL, &info, true);
		} else version(custom_widgets) {
			thumb.positionX = thumbPosition();
			thumb.thumbWidth = thumbSize;
			thumb.redraw();
		} else static assert(0);
	}

	this(Widget parent) {
		super(parent);

		version(win32_widgets) {
			createWin32Window(this, "Scrollbar"w, "", 
				0|WS_CHILD|WS_VISIBLE|SBS_HORZ|SBS_BOTTOMALIGN, 0);
		} else version(custom_widgets) {
			auto vl = new HorizontalLayout(this);
			auto leftButton = new ArrowButton(ArrowDirection.left, vl);
			leftButton.setClickRepeat(scrollClickRepeatInterval);
			thumb = new MouseTrackingWidget(MouseTrackingWidget.Orientation.horizontal, vl);
			auto rightButton = new ArrowButton(ArrowDirection.right, vl);
			rightButton.setClickRepeat(scrollClickRepeatInterval);

			leftButton.tabStop = false;
			rightButton.tabStop = false;
			thumb.tabStop = false;

			leftButton.addEventListener(EventType.triggered, () {
				this.emitCommand!"scrolltopreviousline"();
				//informProgramThatUserChangedPosition(position - step());
			});
			rightButton.addEventListener(EventType.triggered, () {
				this.emitCommand!"scrolltonextline"();
				//informProgramThatUserChangedPosition(position + step());
			});

			thumb.thumbWidth = this.minWidth;
			thumb.thumbHeight = 16;

			thumb.addEventListener(EventType.change, () {
				auto sx = thumb.positionX * max() / thumb.width;
				//informProgramThatUserChangedPosition(sx);

				auto ev = new ScrollToPositionEvent(this, sx);
				ev.dispatch();
			});
		}
	}

	override int minHeight() { return 16; }
	override int maxHeight() { return 16; }
	override int minWidth() { return 48; }
}

class ScrollToPositionEvent : Event {
	this(Widget target, int value) {
		this.value = value;
		super("scrolltoposition", target);
	}

	immutable int value;

	override @property int intValue() {
		return value;
	}
}

//version(custom_widgets)
//private
class VerticalScrollbar : ScrollbarBase {

	version(custom_widgets) {
		override int getBarDim() {
			return thumb.height;
		}

		private MouseTrackingWidget thumb;
	}

	override void setViewableArea(int a) {
		super.setViewableArea(a);

		version(win32_widgets) {
			SCROLLINFO info;
			info.cbSize = info.sizeof;
			info.nPage = a + 1;
			info.fMask = SIF_PAGE;
			SetScrollInfo(hwnd, SB_CTL, &info, true);
		} else version(custom_widgets) {
			thumb.positionY = thumbPosition;
			thumb.thumbHeight = thumbSize;
			thumb.redraw();
		} else static assert(0);

	}

	override void setMax(int a) {
		super.setMax(a);
		version(win32_widgets) {
			SCROLLINFO info;
			info.cbSize = info.sizeof;
			info.nMin = 0;
			info.nMax = max;
			info.fMask = SIF_RANGE;
			SetScrollInfo(hwnd, SB_CTL, &info, true);
		} else version(custom_widgets) {
			thumb.positionY = thumbPosition;
			thumb.thumbHeight = thumbSize;
			thumb.redraw();
		}
	}

	override void setPosition(int a) {
		super.setPosition(a);
		version(win32_widgets) {
			SCROLLINFO info;
			info.cbSize = info.sizeof;
			info.fMask = SIF_POS;
			info.nPos = position;
			SetScrollInfo(hwnd, SB_CTL, &info, true);
		} else version(custom_widgets) {
			thumb.positionY = thumbPosition;
			thumb.thumbHeight = thumbSize;
			thumb.redraw();
		} else static assert(0);
	}

	this(Widget parent) {
		super(parent);

		version(win32_widgets) {
			createWin32Window(this, "Scrollbar"w, "", 
				0|WS_CHILD|WS_VISIBLE|SBS_VERT|SBS_RIGHTALIGN, 0);
		} else version(custom_widgets) {
			auto vl = new VerticalLayout(this);
			auto upButton = new ArrowButton(ArrowDirection.up, vl);
			upButton.setClickRepeat(scrollClickRepeatInterval);
			thumb = new MouseTrackingWidget(MouseTrackingWidget.Orientation.vertical, vl);
			auto downButton = new ArrowButton(ArrowDirection.down, vl);
			downButton.setClickRepeat(scrollClickRepeatInterval);

			upButton.addEventListener(EventType.triggered, () {
				this.emitCommand!"scrolltopreviousline"();
				//informProgramThatUserChangedPosition(position - step());
			});
			downButton.addEventListener(EventType.triggered, () {
				this.emitCommand!"scrolltonextline"();
				//informProgramThatUserChangedPosition(position + step());
			});

			thumb.thumbWidth = this.minWidth;
			thumb.thumbHeight = 16;

			thumb.addEventListener(EventType.change, () {
				auto sy = thumb.positionY * max() / thumb.height;

				auto ev = new ScrollToPositionEvent(this, sy);
				ev.dispatch();

				//informProgramThatUserChangedPosition(sy);
			});

			upButton.tabStop = false;
			downButton.tabStop = false;
			thumb.tabStop = false;
		}
	}

	override int minWidth() { return 16; }
	override int maxWidth() { return 16; }
	override int minHeight() { return 48; }
}


/++
	EXPERIMENTAL

	A widget specialized for being a container for other widgets.

	History:
		Added May 29, 2021. Not stabilized at this time.
+/
class WidgetContainer : Widget {
	this(Widget parent) {
		tabStop = false;
		super(parent);
	}

	override int maxHeight() {
		if(this.children.length == 1) {
			return saturatedSum(this.children[0].maxHeight, this.children[0].marginTop, this.children[0].marginBottom);
		} else {
			return int.max;
		}
	}

	override int maxWidth() {
		if(this.children.length == 1) {
			return saturatedSum(this.children[0].maxWidth, this.children[0].marginLeft, this.children[0].marginRight);
		} else {
			return int.max;
		}
	}

	/+

	override int minHeight() {
		int largest = 0;
		int margins = 0;
		int lastMargin = 0;
		foreach(child; children) {
			auto mh = child.minHeight();
			if(mh > largest)
				largest = mh;
			margins += mymax(lastMargin, child.marginTop());
			lastMargin = child.marginBottom();
		}
		return largest + margins;
	}

	override int maxHeight() {
		int largest = 0;
		int margins = 0;
		int lastMargin = 0;
		foreach(child; children) {
			auto mh = child.maxHeight();
			if(mh == int.max)
				return int.max;
			if(mh > largest)
				largest = mh;
			margins += mymax(lastMargin, child.marginTop());
			lastMargin = child.marginBottom();
		}
		return largest + margins;
	}

	override int minWidth() {
		int min;
		foreach(child; children) {
			auto cm = child.minWidth;
			if(cm > min)
				min = cm;
		}
		return min + paddingLeft + paddingRight;
	}

	override int minHeight() {
		int min;
		foreach(child; children) {
			auto cm = child.minHeight;
			if(cm > min)
				min = cm;
		}
		return min + paddingTop + paddingBottom;
	}

	override int maxHeight() {
		int largest = 0;
		int margins = 0;
		int lastMargin = 0;
		foreach(child; children) {
			auto mh = child.maxHeight();
			if(mh == int.max)
				return int.max;
			if(mh > largest)
				largest = mh;
			margins += mymax(lastMargin, child.marginTop());
			lastMargin = child.marginBottom();
		}
		return largest + margins;
	}

	override int heightStretchiness() {
		int max;
		foreach(child; children) {
			auto c = child.heightStretchiness;
			if(c > max)
				max = c;
		}
		return max;
	}

	override int marginTop() {
		if(this.children.length)
			return this.children[0].marginTop;
		return 0;
	}
	+/
}

///
abstract class Layout : Widget {
	this(Widget parent) {
		tabStop = false;
		super(parent);
	}
}

/++
	Makes all children minimum width and height, placing them down
	left to right, top to bottom.

	Useful if you want to make a list of buttons that automatically
	wrap to a new line when necessary.
+/
class InlineBlockLayout : Layout {
	///
	this(Widget parent) { super(parent); }

	override void recomputeChildLayout() {
		registerMovement();

		int x = this.paddingLeft, y = this.paddingTop;

		int lineHeight;
		int previousMargin = 0;
		int previousMarginBottom = 0;

		foreach(child; children) {
			if(child.hidden)
				continue;
			if(cast(FixedPosition) child) {
				child.recomputeChildLayout();
				continue;
			}
			child.width = child.minWidth();
			if(child.width == 0)
				child.width = 32;
			child.height = child.minHeight();
			if(child.height == 0)
				child.height = 32;

			if(x + child.width + paddingRight > this.width) {
				x = this.paddingLeft;
				y += lineHeight;
				lineHeight = 0;
				previousMargin = 0;
				previousMarginBottom = 0;
			}

			auto margin = child.marginLeft;
			if(previousMargin > margin)
				margin = previousMargin;

			x += margin;

			child.x = x;
			child.y = y;

			int marginTopApplied;
			if(child.marginTop > previousMarginBottom) {
				child.y += child.marginTop;
				marginTopApplied = child.marginTop;
			}

			x += child.width;
			previousMargin = child.marginRight;

			if(child.marginBottom > previousMarginBottom)
				previousMarginBottom = child.marginBottom;

			auto h = child.height + previousMarginBottom + marginTopApplied;
			if(h > lineHeight)
				lineHeight = h;

			child.recomputeChildLayout();
		}

	}

	override int minWidth() {
		int min;
		foreach(child; children) {
			auto cm = child.minWidth;
			if(cm > min)
				min = cm;
		}
		return min + paddingLeft + paddingRight;
	}

	override int minHeight() {
		int min;
		foreach(child; children) {
			auto cm = child.minHeight;
			if(cm > min)
				min = cm;
		}
		return min + paddingTop + paddingBottom;
	}
}

/++
	A tab widget is a set of clickable tab buttons followed by a content area.


	Tabs can change existing content or can be new pages.

	When the user picks a different tab, a `change` message is generated.
+/
class TabWidget : Widget {
	this(Widget parent) {
		super(parent);

		tabStop = false;

		version(win32_widgets) {
			createWin32Window(this, WC_TABCONTROL, "", 0);
		} else version(custom_widgets) {
			addEventListener((ClickEvent event) {
				if(event.target !is this) return;
				if(event.clientY < tabBarHeight) {
					auto t = (event.clientX / tabWidth);
					if(t >= 0 && t < children.length)
						setCurrentTab(t);
				}
			});
		} else static assert(0);
	}

	override int marginTop() { return 4; }
	override int paddingBottom() { return 4; }

	override int minHeight() {
		int max = 0;
		foreach(child; children)
			max = mymax(child.minHeight, max);


		version(win32_widgets) {
			RECT rect;
			rect.right = this.width;
			rect.bottom = max;
			TabCtrl_AdjustRect(hwnd, true, &rect);

			max = rect.bottom;
		} else {
			max += Window.lineHeight + 4;
		}


		return max;
	}

	version(win32_widgets)
	override int handleWmNotify(NMHDR* hdr, int code) {
		switch(code) {
			case TCN_SELCHANGE:
				auto sel = TabCtrl_GetCurSel(hwnd);
				showOnly(sel);
			break;
			default:
		}
		return 0;
	}

	override void addChild(Widget child, int pos = int.max) {
		if(auto twp = cast(TabWidgetPage) child) {
			super.addChild(child, pos);
			if(pos == int.max)
				pos = cast(int) this.children.length - 1;

			version(win32_widgets) {
				TCITEM item;
				item.mask = TCIF_TEXT;
				WCharzBuffer buf = WCharzBuffer(twp.title);
				item.pszText = buf.ptr;
				SendMessage(hwnd, TCM_INSERTITEM, pos, cast(LPARAM) &item);
			} else version(custom_widgets) {
			}

			if(pos != getCurrentTab) {
				child.showing = false;
			}
		} else {
			assert(0, "Don't add children directly to a tab widget, instead add them to a page (see addPage)");
		}
	}

	override void recomputeChildLayout() {
		version(win32_widgets) {
			this.registerMovement();

			RECT rect;
			GetWindowRect(hwnd, &rect);

			auto left = rect.left;
			auto top = rect.top;

			TabCtrl_AdjustRect(hwnd, false, &rect);
			foreach(child; children) {
				child.x = rect.left - left;
				child.y = rect.top - top;
				child.width = rect.right - rect.left;
				child.height = rect.bottom - rect.top;
				child.recomputeChildLayout();
			}
		} else version(custom_widgets) {
			this.registerMovement();
			foreach(child; children) {
				child.x = 2;
				child.y = tabBarHeight + 2; // for the border
				child.width = width - 4; // for the border
				child.height = height - tabBarHeight - 2 - 2; // for the border
				child.recomputeChildLayout();
			}
		} else static assert(0);
	}

	version(custom_widgets) {
		private int currentTab_;
		private int tabBarHeight() { return Window.lineHeight; }
		int tabWidth = 80;
	}

	version(win32_widgets)
	override void paint(WidgetPainter painter) {}

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		auto cs = getComputedStyle();

		draw3dFrame(0, tabBarHeight - 2, width, height - tabBarHeight + 2, painter, FrameStyle.risen, cs.background.color);

		int posX = 0;
		foreach(idx, child; children) {
			if(auto twp = cast(TabWidgetPage) child) {
				auto isCurrent = idx == getCurrentTab();

				painter.setClipRectangle(Point(posX, 0), tabWidth, tabBarHeight);

				draw3dFrame(posX, 0, tabWidth, tabBarHeight, painter, isCurrent ? FrameStyle.risen : FrameStyle.sunk, isCurrent ? cs.windowBackgroundColor : darken(cs.windowBackgroundColor, 0.1));
				painter.outlineColor = cs.foregroundColor;
				painter.drawText(Point(posX + 4, 2), twp.title);

				if(isCurrent) {
					painter.outlineColor = cs.windowBackgroundColor;
					painter.fillColor = Color.transparent;
					painter.drawLine(Point(posX + 2, tabBarHeight - 1), Point(posX + tabWidth, tabBarHeight - 1));
					painter.drawLine(Point(posX + 2, tabBarHeight - 2), Point(posX + tabWidth, tabBarHeight - 2));

					painter.outlineColor = Color.white;
					painter.drawPixel(Point(posX + 1, tabBarHeight - 1));
					painter.drawPixel(Point(posX + 1, tabBarHeight - 2));
					painter.outlineColor = cs.activeTabColor;
					painter.drawPixel(Point(posX, tabBarHeight - 1));
				}

				posX += tabWidth - 2;
			}
		}
	}

	///
	@scriptable
	void setCurrentTab(int item) {
		version(win32_widgets)
			TabCtrl_SetCurSel(hwnd, item);
		else version(custom_widgets)
			currentTab_ = item;
		else static assert(0);

		showOnly(item);
	}

	///
	@scriptable
	int getCurrentTab() {
		version(win32_widgets)
			return TabCtrl_GetCurSel(hwnd);
		else version(custom_widgets)
			return currentTab_; // FIXME
		else static assert(0);
	}

	///
	@scriptable
	void removeTab(int item) {
		if(item && item == getCurrentTab())
			setCurrentTab(item - 1);

		version(win32_widgets) {
			TabCtrl_DeleteItem(hwnd, item);
		}

		for(int a = item; a < children.length - 1; a++)
			this._children[a] = this._children[a + 1];
		this._children = this._children[0 .. $-1];
	}

	///
	@scriptable
	TabWidgetPage addPage(string title) {
		return new TabWidgetPage(title, this);
	}

	private void showOnly(int item) {
		foreach(idx, child; children) {
			child.hide();
		}

		foreach(idx, child; children) {
			if(idx == item) {
				child.show();
				recomputeChildLayout();
			}
		}

		version(win32_widgets) {
			InvalidateRect(parentWindow.hwnd, null, true);
		}
	}
}

/++
	A page widget is basically a tab widget with hidden tabs.

	You add [TabWidgetPage]s to it.
+/
class PageWidget : Widget {
	this(Widget parent) {
		super(parent);
	}

	override int minHeight() {
		int max = 0;
		foreach(child; children)
			max = mymax(child.minHeight, max);

		return max;
	}


	override void addChild(Widget child, int pos = int.max) {
		if(auto twp = cast(TabWidgetPage) child) {
			super.addChild(child, pos);
			if(pos == int.max)
				pos = cast(int) this.children.length - 1;

			if(pos != getCurrentTab) {
				child.showing = false;
			}
		} else {
			assert(0, "Don't add children directly to a page widget, instead add them to a page (see addPage)");
		}
	}

	override void recomputeChildLayout() {
		this.registerMovement();
		foreach(child; children) {
			child.x = 0;
			child.y = 0;
			child.width = width;
			child.height = height;
			child.recomputeChildLayout();
		}
	}

	private int currentTab_;

	///
	@scriptable
	void setCurrentTab(int item) {
		currentTab_ = item;

		showOnly(item);
	}

	///
	@scriptable
	int getCurrentTab() {
		return currentTab_;
	}

	///
	@scriptable
	void removeTab(int item) {
		if(item && item == getCurrentTab())
			setCurrentTab(item - 1);

		for(int a = item; a < children.length - 1; a++)
			this._children[a] = this._children[a + 1];
		this._children = this._children[0 .. $-1];
	}

	///
	@scriptable
	TabWidgetPage addPage(string title) {
		return new TabWidgetPage(title, this);
	}

	private void showOnly(int item) {
		foreach(idx, child; children)
			if(idx == item) {
				child.show();
				child.recomputeChildLayout();
			} else {
				child.hide();
			}
	}

}

/++

+/
class TabWidgetPage : Widget {
	string title;
	this(string title, Widget parent) {
		this.title = title;
		this.tabStop = false;
		super(parent);

		///*
		version(win32_widgets) {
			static bool classRegistered = false;
			if(!classRegistered) {
				HINSTANCE hInstance = cast(HINSTANCE) GetModuleHandle(null);
				WNDCLASSEX wc;
				wc.cbSize = wc.sizeof;
				wc.hInstance = hInstance;
				wc.hbrBackground = cast(HBRUSH) (COLOR_3DFACE+1); // GetStockObject(WHITE_BRUSH);
				wc.lpfnWndProc = &DefWindowProc;
				wc.lpszClassName = "arsd_minigui_TabWidgetPage"w.ptr;
				if(!RegisterClassExW(&wc))
					throw new Exception("RegisterClass ");// ~ to!string(GetLastError()));
				classRegistered = true;
			}


			createWin32Window(this, "arsd_minigui_TabWidgetPage"w, "", 0);
		}
		//*/
	}

	override int minHeight() {
		int sum = 0;
		foreach(child; children)
			sum += child.minHeight();
		return sum;
	}
}

version(none)
class CollapsableSidebar : Widget {

}

/// Stacks the widgets vertically, taking all the available width for each child.
class VerticalLayout : Layout {
	// intentionally blank - widget's default is vertical layout right now
	///
	this(Widget parent) { super(parent); }
}

/// Stacks the widgets horizontally, taking all the available height for each child.
class HorizontalLayout : Layout {
	///
	this(Widget parent) { super(parent); }
	override void recomputeChildLayout() {
		.recomputeChildLayout!"width"(this);
	}

	override int minHeight() {
		int largest = 0;
		int margins = 0;
		int lastMargin = 0;
		foreach(child; children) {
			auto mh = child.minHeight();
			if(mh > largest)
				largest = mh;
			margins += mymax(lastMargin, child.marginTop());
			lastMargin = child.marginBottom();
		}
		return largest + margins;
	}

	override int maxHeight() {
		int largest = 0;
		int margins = 0;
		int lastMargin = 0;
		foreach(child; children) {
			auto mh = child.maxHeight();
			if(mh == int.max)
				return int.max;
			if(mh > largest)
				largest = mh;
			margins += mymax(lastMargin, child.marginTop());
			lastMargin = child.marginBottom();
		}
		return largest + margins;
	}

	override int heightStretchiness() {
		int max;
		foreach(child; children) {
			auto c = child.heightStretchiness;
			if(c > max)
				max = c;
		}
		return max;
	}

}

/++
	A widget that takes your widget, puts scroll bars around it, and sends
	messages to it when the user scrolls. Unlike [ScrollableWidget], it makes
	no effort to automatically scroll or clip its child widgets - it just sends
	the messages.


	A ScrollMessageWidget notifies you with a [ScrollEvent] that it has changed.
	The scroll coordinates are all given in a unit you interpret as you wish. One
	of these units is moved on each press of the arrow buttons and represents the
	smallest amount the user can scroll. The intention is for this to be one line,
	one item in a list, one row in a table, etc. Whatever makes sense for your widget
	in each direction that the user might be interested in.

	You can set a "page size" with the [step] property. (Yes, I regret the name...)
	This is the amount it jumps when the user pressed page up and page down, or clicks
	in the exposed part of the scroll bar.

	You should add child content to the ScrollMessageWidget. However, it is important to
	note that the coordinates are always independent of the scroll position! It is YOUR
	responsibility to do any necessary transforms, clipping, etc., while drawing the
	content and interpreting mouse events if they are supposed to change with the scroll.
	This is in contrast to the (likely to be deprecated) [ScrollableWidget], which tries
	to maintain the illusion that there's an infinite space. The [ScrollMessageWidget] gives
	you more control (which can be considerably more efficient and adapted to your actual data)
	at the expense of you also needing to be aware of its reality.
+/
class ScrollMessageWidget : Widget {
	this(Widget parent) {
		super(parent);

		container = new Widget(this);
		hsb = new HorizontalScrollbar(this);
		vsb = new VerticalScrollbar(this);

		hsb.addEventListener("scrolltonextline", {
			hsb.setPosition(hsb.position + 1);
			notify();
		});
		hsb.addEventListener("scrolltopreviousline", {
			hsb.setPosition(hsb.position - 1);
			notify();
		});
		vsb.addEventListener("scrolltonextline", {
			vsb.setPosition(vsb.position + 1);
			notify();
		});
		vsb.addEventListener("scrolltopreviousline", {
			vsb.setPosition(vsb.position - 1);
			notify();
		});
		hsb.addEventListener("scrolltonextpage", {
			hsb.setPosition(hsb.position + hsb.step_);
			notify();
		});
		hsb.addEventListener("scrolltopreviouspage", {
			hsb.setPosition(hsb.position - hsb.step_);
			notify();
		});
		vsb.addEventListener("scrolltonextpage", {
			vsb.setPosition(vsb.position + vsb.step_);
			notify();
		});
		vsb.addEventListener("scrolltopreviouspage", {
			vsb.setPosition(vsb.position - vsb.step_);
			notify();
		});
		hsb.addEventListener("scrolltoposition", (Event event) {
			hsb.setPosition(event.intValue);
			notify();
		});
		vsb.addEventListener("scrolltoposition", (Event event) {
			vsb.setPosition(event.intValue);
			notify();
		});


		tabStop = false;
		container.tabStop = false;
		magic = true;
	}

	///
	void scrollUp() {
		vsb.setPosition(vsb.position - 1);
		notify();
	}
	/// Ditto
	void scrollDown() {
		vsb.setPosition(vsb.position + 1);
		notify();
	}

	///
	VerticalScrollbar verticalScrollBar() { return vsb; }
	///
	HorizontalScrollbar horizontalScrollBar() { return hsb; }

	void notify() {
		this.emit!ScrollEvent();
	}

	mixin Emits!ScrollEvent;

	///
	Point position() {
		return Point(hsb.position, vsb.position);
	}

	///
	void setPosition(int x, int y) {
		hsb.setPosition(x);
		vsb.setPosition(y);
	}

	///
	void setPageSize(int unitsX, int unitsY) {
		hsb.setStep(unitsX);
		vsb.setStep(unitsY);
	}

	///
	void setTotalArea(int width, int height) {
		hsb.setMax(width);
		vsb.setMax(height);
	}

	///
	void setViewableArea(int width, int height) {
		hsb.setViewableArea(width);
		vsb.setViewableArea(height);
	}

	private bool magic;
	override void addChild(Widget w, int position = int.max) {
		if(magic)
			container.addChild(w, position);
		else
			super.addChild(w, position);
	}

	override void recomputeChildLayout() {
		if(hsb is null || vsb is null || container is null) return;

		registerMovement();

		hsb.height = 16; // FIXME? are tese 16s sane?
		hsb.x = 0;
		hsb.y = this.height - hsb.height;
		hsb.width = this.width - 16;
		hsb.recomputeChildLayout();

		vsb.width = 16; // FIXME?
		vsb.x = this.width - vsb.width;
		vsb.y = 0;
		vsb.height = this.height - 16;
		vsb.recomputeChildLayout();

		container.x = 0;
		container.y = 0;
		container.width = this.width - vsb.width;
		container.height = this.height - hsb.height;
		container.recomputeChildLayout();
	}

	HorizontalScrollbar hsb;
	VerticalScrollbar vsb;
	Widget container;
}

/++
	Bypasses automatic layout for its children, using manual positioning and sizing only.
	While you need to manually position them, you must ensure they are inside the StaticLayout's
	bounding box to avoid undefined behavior.

	You should almost never use this.
+/
class StaticLayout : Layout {
	///
	this(Widget parent) { super(parent); }
	override void recomputeChildLayout() {
		registerMovement();
		foreach(child; children)
			child.recomputeChildLayout();
	}
}

/++
	Bypasses automatic positioning when being laid out. It is your responsibility to make
	room for this widget in the parent layout.

	Its children are laid out normally, unless there is exactly one, in which case it takes
	on the full size of the `StaticPosition` object (if you plan to put stuff on the edge, you
	can do that with `padding`).
+/
class StaticPosition : Layout {
	///
	this(Widget parent) { super(parent); }

	override void recomputeChildLayout() {
		registerMovement();
		if(this.children.length == 1) {
			auto child = children[0];
			child.x = 0;
			child.y = 0;
			child.width = this.width;
			child.height = this.height;
			child.recomputeChildLayout();
		} else
		foreach(child; children)
			child.recomputeChildLayout();
	}

}

/++
	FixedPosition is like [StaticPosition], but its coordinates
	are always relative to the viewport, meaning they do not scroll with
	the parent content.
+/
class FixedPosition : StaticPosition {
	///
	this(Widget parent) { super(parent); }
}

version(win32_widgets)
int processWmCommand(HWND parentWindow, HWND handle, ushort cmd, ushort idm) {
	if(true) {
		// cmd == 0 = menu, cmd == 1 = accelerator
		if(auto item = idm in Action.mapping) {
			foreach(handler; (*item).triggered)
				handler();
		/*
			auto event = new Event("triggered", *item);
			event.button = idm;
			event.dispatch();
		*/
			return 0;
		}
	}
	if(handle)
	if(auto widgetp = handle in Widget.nativeMapping) {
		(*widgetp).handleWmCommand(cmd, idm);
		return 0;
	}
	return 1;
}


///
class Window : Widget {
	int mouseCaptureCount = 0;
	Widget mouseCapturedBy;
	void captureMouse(Widget byWhom) {
		assert(mouseCapturedBy is null || byWhom is mouseCapturedBy);
		mouseCaptureCount++;
		mouseCapturedBy = byWhom;
		win.grabInput();
	}
	void releaseMouseCapture() {
		mouseCaptureCount--;
		mouseCapturedBy = null;
		win.releaseInputGrab();
	}

	///
	@scriptable
	@property bool focused() {
		return win.focused;
	}

	static class Style : Widget.Style {
		override WidgetBackground background() {
			version(custom_widgets)
				return WidgetBackground(WidgetPainter.visualTheme.windowBackgroundColor);
			else version(win32_widgets)
				return WidgetBackground(Color.transparent);
			else static assert(0);
		}
	}
	mixin OverrideStyle!Style;

	/++
		Gives the height of a line according to the default font. You should try to use your computed font instead of this, but until May 8, 2021, this was the only real option.
	+/
	static int lineHeight() {
		OperatingSystemFont font;
		if(auto vt = WidgetPainter.visualTheme) {
			font = vt.defaultFontCached();
		}

		if(font is null) {
			static int defaultHeightCache;
			if(defaultHeightCache == 0) {
				font = new OperatingSystemFont;
				font.loadDefault;
				defaultHeightCache = font.height() * 5 / 4;
			}
			return defaultHeightCache;
		}

		return font.height() * 5 / 4;
	}

	Widget focusedWidget;

	SimpleWindow win;

	/// YOU ALMOST CERTAINLY SHOULD NOT USE THIS. This is really only for special purposes like pseudowindows or popup windows doing their own thing.
	this(Widget p) {
		tabStop = false;
		super(p);
	}

	private bool skipNextChar = false;

	///
	this(SimpleWindow win) {

		static if(UsingSimpledisplayX11) {
			win.discardAdditionalConnectionState = &discardXConnectionState;
			win.recreateAdditionalConnectionState = &recreateXConnectionState;
		}

		tabStop = false;
		super(null);
		this.win = win;

		win.addEventListener((Widget.RedrawEvent) {
			//import std.stdio; writeln("redrawing");
			this.actualRedraw();
		});

		this.width = win.width;
		this.height = win.height;
		this.parentWindow = this;

		win.windowResized = (int w, int h) {
			this.width = w;
			this.height = h;
			recomputeChildLayout();
			version(win32_widgets)
				InvalidateRect(hwnd, null, true);
			redraw();
		};

		win.onFocusChange = (bool getting) {
			if(this.focusedWidget) {
				if(getting)
					this.focusedWidget.emit!FocusEvent();
				else
					this.focusedWidget.emit!BlurEvent();
			}

			if(getting)
				this.emit!FocusEvent();
			else
				this.emit!BlurEvent();
		};

		win.setEventHandlers(
			(MouseEvent e) {
				dispatchMouseEvent(e);
			},
			(KeyEvent e) {
				//import std.stdio;
				//writefln("%x   %s", cast(uint) e.key, e.key);
				dispatchKeyEvent(e);
			},
			(dchar e) {
				if(e == 13) e = 10; // hack?
				if(e == 127) return; // linux sends this, windows doesn't. we don't want it.
				dispatchCharEvent(e);
			},
		);

		addEventListener("char", (Widget, Event ev) {
			if(skipNextChar) {
				ev.preventDefault();
				skipNextChar = false;
			}
		});

		version(win32_widgets)
		win.handleNativeEvent = delegate int(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {

			if(hwnd !is this.win.impl.hwnd)
				return 1; // we don't care...
			switch(msg) {

				case WM_VSCROLL, WM_HSCROLL:
					auto pos = HIWORD(wParam);
					auto m = LOWORD(wParam);

					auto scrollbarHwnd = cast(HWND) lParam;


					if(auto widgetp = scrollbarHwnd in Widget.nativeMapping) {

						//auto smw = cast(ScrollMessageWidget) widgetp.parent;

						switch(m) {
							/+
							// I don't think those messages are ever actually sent normally by the widget itself,
							// they are more used for the keyboard interface. methinks.
							case SB_BOTTOM:
								import std.stdio; writeln("end");
								auto event = new Event("scrolltoend", *widgetp);
								event.dispatch();
								//if(!event.defaultPrevented)
							break;
							case SB_TOP:
								import std.stdio; writeln("top");
								auto event = new Event("scrolltobeginning", *widgetp);
								event.dispatch();
							break;
							case SB_ENDSCROLL:
								// idk
							break;
							+/
							case SB_LINEDOWN:
								this.emitCommand!"scrolltonextline"();
							break;
							case SB_LINEUP:
								this.emitCommand!"scrolltopreviousline"();
							break;
							case SB_PAGEDOWN:
								this.emitCommand!"scrolltonextpage"();
							break;
							case SB_PAGEUP:
								this.emitCommand!"scrolltopreviouspage"();
							break;
							case SB_THUMBPOSITION:
								auto ev = new ScrollToPositionEvent(*widgetp, pos);
								ev.dispatch();
							break;
							case SB_THUMBTRACK:
								// eh kinda lying but i like the real time update display
								auto ev = new ScrollToPositionEvent(*widgetp, pos);
								ev.dispatch();
								// the event loop doesn't seem to carry on with a requested redraw..
								// so we request it to get our dirty bit set...
								// then we need to immediately actually redraw it too for instant feedback to user
								if(redrawRequested)
									actualRedraw();
							break;
							default:
						}
					} else {
						return 1;
					}
				break;

				case WM_CONTEXTMENU:
					auto hwndFrom = cast(HWND) wParam;

					auto xPos = cast(short) LOWORD(lParam); 
					auto yPos = cast(short) HIWORD(lParam); 

					if(auto widgetp = hwndFrom in Widget.nativeMapping) {
						POINT p;
						p.x = xPos;
						p.y = yPos;
						ScreenToClient(hwnd, &p);
						auto clientX = cast(ushort) p.x;
						auto clientY = cast(ushort) p.y;

						auto wap = widgetAtPoint(*widgetp, clientX, clientY);

						if(!wap.widget.showContextMenu(wap.x, wap.y, xPos, yPos))
							return 1; // it didn't show above, pass message on
					}
				break;

				case WM_NOTIFY:
					auto hdr = cast(NMHDR*) lParam;
					auto hwndFrom = hdr.hwndFrom;
					auto code = hdr.code;

					if(auto widgetp = hwndFrom in Widget.nativeMapping) {
						return (*widgetp).handleWmNotify(hdr, code);
					}
				break;
				case WM_COMMAND:
					auto handle = cast(HWND) lParam;
					auto cmd = HIWORD(wParam);
					return processWmCommand(hwnd, handle, cmd, LOWORD(wParam));

				default: return 1; // not handled, pass it on
			}
			return 0;
		};
	}

	version(win32_widgets)
	override void paint(WidgetPainter painter) {
		/*
		RECT rect;
		rect.right = this.width;
		rect.bottom = this.height;
		DrawThemeBackground(theme, painter.impl.hdc, 4, 1, &rect, null);
		*/
		// 3dface is used as window backgrounds by Windows too, so that's why I'm using it here
		auto b = SelectObject(painter.impl.hdc, GetSysColorBrush(COLOR_3DFACE));
		auto p = SelectObject(painter.impl.hdc, GetStockObject(NULL_PEN));
		// since the pen is null, to fill the whole space, we need the +1 on both.
		gdi.Rectangle(painter.impl.hdc, 0, 0, this.width + 1, this.height + 1);
		SelectObject(painter.impl.hdc, p);
		SelectObject(painter.impl.hdc, b);
	}
	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		auto cs = getComputedStyle();
		painter.fillColor = cs.windowBackgroundColor;
		painter.outlineColor = cs.windowBackgroundColor;
		painter.drawRectangle(Point(0, 0), this.width, this.height);
	}


	override void defaultEventHandler_keydown(KeyDownEvent event) {
		Widget _this = event.target;

		if(event.key == Key.Tab) {
			/* Window tab ordering is a recursive thingy with each group */

			// FIXME inefficient
			Widget[] helper(Widget p) {
				if(p.hidden)
					return null;
				Widget[] childOrdering;

				auto children = p.children.dup;

				while(true) {
					// UIs should be generally small, so gonna brute force it a little
					// note that it must be a stable sort here; if all are index 0, it should be in order of declaration

					Widget smallestTab;
					foreach(ref c; children) {
						if(c is null) continue;
						if(smallestTab is null || c.tabOrder < smallestTab.tabOrder) {
							smallestTab = c;
							c = null;
						}
					}
					if(smallestTab !is null) {
						if(smallestTab.tabStop && !smallestTab.hidden)
							childOrdering ~= smallestTab;
						if(!smallestTab.hidden)
							childOrdering ~= helper(smallestTab);
					} else
						break;

				}

				return childOrdering;
			}

			Widget[] tabOrdering = helper(this);

			Widget recipient;

			if(tabOrdering.length) {
				bool seenThis = false;
				Widget previous;
				foreach(idx, child; tabOrdering) {
					if(child is focusedWidget) {

						if(event.shiftKey) {
							if(idx == 0)
								recipient = tabOrdering[$-1];
							else
								recipient = tabOrdering[idx - 1];
							break;
						}

						seenThis = true;
						if(idx + 1 == tabOrdering.length) {
							// we're at the end, either move to the next group
							// or start back over
							recipient = tabOrdering[0];
						}
						continue;
					}
					if(seenThis) {
						recipient = child;
						break;
					}
					previous = child;
				}
			}

			if(recipient !is null) {
				// import std.stdio; writeln(typeid(recipient));
				recipient.focus();

				skipNextChar = true;
			}
		}

		debug if(event.key == Key.F12) {
			if(devTools) {
				devTools.close();
				devTools = null;
			} else {
				devTools = new DevToolWindow(this);
				devTools.show();
			}
		}
	}

	debug DevToolWindow devTools;


	/++
		History:
			Prior to May 12, 2021, the default title was "D Application" (simpledisplay.d's default). After that, the default is Runtime.args[0] instead.
	+/
	this(int width = 500, int height = 500, string title = null) {
		if(title is null) {
			import core.runtime;
			if(Runtime.args.length)
				title = Runtime.args[0];
		}
		win = new SimpleWindow(width, height, title, OpenGlOptions.no, Resizability.allowResizing, WindowTypes.normal, WindowFlags.dontAutoShow);
		this(win);
	}

	///
	this(string title) {
		this(500, 500, title);
	}

	///
	@scriptable
	void close() {
		win.close();
		// I synchronize here upon window closing to ensure all child windows
		// get updated too before the event loop. This avoids some random X errors.
		static if(UsingSimpledisplayX11) {
			runInGuiThread( {
				XSync(XDisplayConnection.get, false);
			});
		}
	}

	bool dispatchKeyEvent(KeyEvent ev) {
		auto wid = focusedWidget;
		if(wid is null)
			wid = this;
		KeyEventBase event = ev.pressed ? new KeyDownEvent(wid) : new KeyUpEvent(wid);
		event.originalKeyEvent = ev;
		event.key = ev.key;
		event.state = ev.modifierState;
		event.shiftKey = (ev.modifierState & ModifierState.shift) ? true : false;
		event.altKey = (ev.modifierState & ModifierState.alt) ? true : false;
		event.ctrlKey = (ev.modifierState & ModifierState.ctrl) ? true : false;
		event.dispatch();

		return true;
	}

	bool dispatchCharEvent(dchar ch) {
		if(focusedWidget) {
			auto event = new CharEvent(focusedWidget, ch);
			event.dispatch();
		}
		return true;
	}

	Widget mouseLastOver;
	Widget mouseLastDownOn;
	bool lastWasDoubleClick;
	bool dispatchMouseEvent(MouseEvent ev) {
		auto eleR = widgetAtPoint(this, ev.x, ev.y);
		auto ele = eleR.widget;

		auto captureEle = ele;

		if(mouseCapturedBy !is null) {
			if(ele !is mouseCapturedBy && !mouseCapturedBy.isAParentOf(ele))
				captureEle = mouseCapturedBy;
		}

		// a hack to get it relative to the widget.
		eleR.x = ev.x;
		eleR.y = ev.y;
		auto pain = captureEle;
		while(pain) {
			eleR.x -= pain.x;
			eleR.y -= pain.y;
			pain = pain.parent;
		}

		if(ev.type == MouseEventType.buttonPressed) {
			MouseEventBase event = new MouseDownEvent(captureEle);
			event.button = ev.button;
			event.buttonLinear = ev.buttonLinear;
			event.state = ev.modifierState;
			event.clientX = eleR.x;
			event.clientY = eleR.y;
			event.dispatch();

			if(ev.button != MouseButton.wheelDown && ev.button != MouseButton.wheelUp && mouseLastDownOn is ele && ev.doubleClick) {
				event = new DoubleClickEvent(captureEle);
				event.button = ev.button;
				event.buttonLinear = ev.buttonLinear;
				event.state = ev.modifierState;
				event.clientX = eleR.x;
				event.clientY = eleR.y;
				event.dispatch();
				lastWasDoubleClick = ev.doubleClick;
			} else {
				lastWasDoubleClick = false;
			}

			mouseLastDownOn = ele;
		} else if(ev.type == MouseEventType.buttonReleased) {
			{
				auto event = new MouseUpEvent(captureEle);
				event.button = ev.button;
				event.buttonLinear = ev.buttonLinear;
				event.clientX = eleR.x;
				event.clientY = eleR.y;
				event.state = ev.modifierState;
				event.dispatch();
			}
			if(!lastWasDoubleClick && mouseLastDownOn is ele) {
				MouseEventBase event = new ClickEvent(captureEle);
				event.clientX = eleR.x;
				event.clientY = eleR.y;
				event.state = ev.modifierState;
				event.button = ev.button;
				event.buttonLinear = ev.buttonLinear;
				event.dispatch();
			}
		} else if(ev.type == MouseEventType.motion) {
			// motion
			{
				auto event = new MouseMoveEvent(captureEle);
				event.state = ev.modifierState;
				event.clientX = eleR.x;
				event.clientY = eleR.y;
				event.dispatch();
			}

			if(mouseLastOver !is ele) {
				if(ele !is null) {
					if(!isAParentOf(ele, mouseLastOver)) {
						ele.setDynamicState(DynamicState.hover, true);
						auto event = new MouseEnterEvent(ele);
						event.relatedTarget = mouseLastOver;
						event.sendDirectly();

						ele.useStyleProperties((scope Widget.Style s) {
							ele.parentWindow.win.cursor = s.cursor;
						});
					}
				}

				if(mouseLastOver !is null) {
					if(!isAParentOf(mouseLastOver, ele)) {
						mouseLastOver.setDynamicState(DynamicState.hover, false);
						auto event = new MouseLeaveEvent(mouseLastOver);
						event.relatedTarget = ele;
						event.sendDirectly();
					}
				}

				if(ele !is null) {
					auto event = new MouseOverEvent(ele);
					event.relatedTarget = mouseLastOver;
					event.dispatch();
				}

				if(mouseLastOver !is null) {
					auto event = new MouseOutEvent(mouseLastOver);
					event.relatedTarget = ele;
					event.dispatch();
				}

				mouseLastOver = ele;
			}
		}

		return true;
	}

	/// Shows the window and runs the application event loop.
	@scriptable
	void loop() {
		show();
		win.eventLoop(0);
	}

	private bool firstShow = true;

	@scriptable
	override void show() {
		bool rd = false;
		if(firstShow) {
			firstShow = false;
			recomputeChildLayout();
			auto f = getFirstFocusable(this); // FIXME: autofocus?
			if(f)
				f.focus();
			redraw();
		}
		win.show();
		super.show();
	}
	@scriptable
	override void hide() {
		win.hide();
		super.hide();
	}

	static Widget getFirstFocusable(Widget start) {
		if(start.tabStop && !start.hidden)
			return start;

		if(!start.hidden)
		foreach(child; start.children) {
			auto f = getFirstFocusable(child);
			if(f !is null)
				return f;
		}
		return null;
	}
}

debug private class DevToolWindow : Window {
	Window p;

	TextEdit parentList;
	TextEdit logWindow;
	TextLabel clickX, clickY;

	this(Window p) {
		this.p = p;
		super(400, 300, "Developer Toolbox");

		logWindow = new TextEdit(this);
		parentList = new TextEdit(this);

		auto hl = new HorizontalLayout(this);
		clickX = new TextLabel("", hl);
		clickY = new TextLabel("", hl);

		parentListeners ~= p.addEventListener("*", (Event ev) {
			log(typeid(ev.source).name, " emitted ", typeid(ev).name);
		});

		parentListeners ~= p.addEventListener((ClickEvent ev) {
			auto s = ev.srcElement;
			string list = s.toString();
			s = s.parent;
			while(s) {
				list ~= "\n";
				list ~= s.toString();
				s = s.parent;
			}
			parentList.content = list;

			clickX.label = toInternal!string(ev.clientX);
			clickY.label = toInternal!string(ev.clientY);
		});
	}

	EventListener[] parentListeners;

	override void close() {
		assert(p !is null);
		foreach(p; parentListeners)
			p.disconnect();
		parentListeners = null;
		p.devTools = null;
		p = null;
		super.close();
	}

	override void defaultEventHandler_keydown(KeyDownEvent ev) {
		if(ev.key == Key.F12) {
			this.close();
			if(p)
				p.devTools = null;
		} else {
			super.defaultEventHandler_keydown(ev);
		}
	}

	void log(T...)(T t) {
		string str;
		import std.conv;
		foreach(i; t)
			str ~= to!string(i);
		str ~= "\n";
		logWindow.addText(str);

		version(custom_widgets)
		logWindow.ensureVisibleInScroll(logWindow.textLayout.caretBoundingBox());
	}
}

/++
	A dialog is a transient window that intends to get information from
	the user before being dismissed.
+/
abstract class Dialog : Window {
	///
	this(int width, int height, string title = null) {
		super(width, height, title);
	}

	///
	abstract void OK();

	///
	void Cancel() {
		this.close();
	}
}

/++
	A line edit box with an associated label.

	History:
		On May 17, the default internal layout was changed from horizontal to vertical.

		```
		Old: ________

		New:
		____________
		```

		To restore the old behavior, use `new LabeledLineEdit("label", TextAlignment.Right, parent);`
+/
alias LabeledLineEdit = Labeled!LineEdit;

/++
	History:
		Added May 19, 2020
+/
class Labeled(T) : Widget {
	///
	this(string label, Widget parent) {
		super(parent);
		initialize!VerticalLayout(label, TextAlignment.Left, parent);
	}

	/++
		History:
			The alignment parameter was added May 17, 2021
	+/
	this(string label, TextAlignment alignment, Widget parent) {
		super(parent);
		initialize!HorizontalLayout(label, alignment, parent);
	}

	private void initialize(L)(string label, TextAlignment alignment, Widget parent) {
		tabStop = false;
		horizontal = is(L == HorizontalLayout);
		auto hl = new L(this);
		this.label = new TextLabel(label, alignment, hl);
		this.lineEdit = new T(hl);
	}

	private bool horizontal;

	TextLabel label; ///
	T lineEdit; ///

	override int minHeight() { return (horizontal ? 1 : 2) * Window.lineHeight + 4; }
	override int maxHeight() { return (horizontal ? 1 : 2) * Window.lineHeight + 4; }
	override int marginTop() { return 4; }
	override int marginBottom() { return 4; }

	///
	@property string content() {
		return lineEdit.content;
	}
	///
	@property void content(string c) {
		return lineEdit.content(c);
	}

	///
	void selectAll() {
		lineEdit.selectAll();
	}

	override void focus() {
		lineEdit.focus();
	}
}

/++
	A labeled password edit.

	History:
		Added as a class on January 25, 2021, changed into an alias of the new [Labeled] template on May 19, 2021

		The default parameters for the constructors were also removed on May 19, 2021
+/
alias LabeledPasswordEdit = Labeled!PasswordEdit;

private string toMenuLabel(string s) {
	string n;
	n.reserve(s.length);
	foreach(c; s)
		if(c == '_')
			n ~= ' ';
		else
			n ~= c;
	return n;
}

private void delegate() makeAutomaticHandler(alias fn, T)(T t) {
	static if(is(T : void delegate())) {
		return t;
	} else {
		static if(is(typeof(fn) Params == __parameters))
		struct S {
			static if(!__(traits(compiles, mixin(`{ static foreach(i; 1..4) {} }`)))) {
				pragma(msg, "warning: automatic handler of params not yet implemented on your compiler");
			} else mixin(q{
			static foreach(idx, ignore; Params) {
				mixin("Params[idx] " ~ __traits(identifier, Params[idx .. idx + 1]) ~ ";");
			}
			});
		}
		return () {
			dialog((S s) {
				t(s.tupleof);
			}, null, __traits(identifier, fn));
		};
	}
}

private template hasAnyRelevantAnnotations(a...) {
	bool helper() {
		bool any;
		foreach(attr; a) {
			static if(is(typeof(attr) == .menu))
				any = true;
			else static if(is(typeof(attr) == .toolbar))
				any = true;
			else static if(is(attr == .separator))
				any = true;
			else static if(is(typeof(attr) == .accelerator))
				any = true;
			else static if(is(typeof(attr) == .hotkey))
				any = true;
			else static if(is(typeof(attr) == .icon))
				any = true;
			else static if(is(typeof(attr) == .label))
				any = true;
			else static if(is(typeof(attr) == .tip))
				any = true;
		}
		return any;
	}

	enum bool hasAnyRelevantAnnotations = helper();
}

/++
	A `MainWindow` is a window that includes turnkey support for a menu bar, tool bar, and status bar automatically positioned around a client area where you put your widgets.
+/
class MainWindow : Window {
	///
	this(string title = null, int initialWidth = 500, int initialHeight = 500) {
		super(initialWidth, initialHeight, title);

		_clientArea = new ClientAreaWidget();
		_clientArea.x = 0;
		_clientArea.y = 0;
		_clientArea.width = this.width;
		_clientArea.height = this.height;
		_clientArea.tabStop = false;

		super.addChild(_clientArea);

		statusBar = new StatusBar(this);
	}

	/++
		Adds a menu and toolbar from annotated functions.

	---
        struct Commands {
                @menu("File") {
                        void New() {}
                        void Open() {}
                        void Save() {}
                        @separator
                        void Exit() @accelerator("Alt+F4") @hotkey('x') {
                                window.close();
                        }
                }

                @menu("Edit") {
                        void Undo() {
                                undo();
                        }
                        @separator
                        void Cut() {}
                        void Copy() {}
                        void Paste() {}
                }

                @menu("Help") {
                        void About() {}
                }
        }

        Commands commands;

        window.setMenuAndToolbarFromAnnotatedCode(commands);
	---

	Note that you can call this function multiple times and it will add the items in order to the given items.

	+/
	void setMenuAndToolbarFromAnnotatedCode(T)(ref T t) if(!is(T == class) && !is(T == interface)) {
		setMenuAndToolbarFromAnnotatedCode_internal(t);
	}
	void setMenuAndToolbarFromAnnotatedCode(T)(T t) if(is(T == class) || is(T == interface)) {
		setMenuAndToolbarFromAnnotatedCode_internal(t);
	}
	void setMenuAndToolbarFromAnnotatedCode_internal(T)(ref T t) {
		Action[] toolbarActions;
		auto menuBar = this.menuBar is null ? new MenuBar() : this.menuBar;
		Menu[string] mcs;

		foreach(menu; menuBar.subMenus) {
			mcs[menu.label] = menu;
		}

		foreach(memberName; __traits(derivedMembers, T)) {
			static if(memberName != "this")
			static if(hasAnyRelevantAnnotations!(__traits(getAttributes, __traits(getMember, T, memberName)))) {
				.menu menu;
				.toolbar toolbar;
				bool separator;
				.accelerator accelerator;
				.hotkey hotkey;
				.icon icon;
				string label;
				string tip;
				foreach(attr; __traits(getAttributes, __traits(getMember, T, memberName))) {
					static if(is(typeof(attr) == .menu))
						menu = attr;
					else static if(is(typeof(attr) == .toolbar))
						toolbar = attr;
					else static if(is(attr == .separator))
						separator = true;
					else static if(is(typeof(attr) == .accelerator))
						accelerator = attr;
					else static if(is(typeof(attr) == .hotkey))
						hotkey = attr;
					else static if(is(typeof(attr) == .icon))
						icon = attr;
					else static if(is(typeof(attr) == .label))
						label = attr.label;
					else static if(is(typeof(attr) == .tip))
						tip = attr.tip;
				}

				if(menu !is .menu.init || toolbar !is .toolbar.init) {
					ushort correctIcon = icon.id; // FIXME
					if(label.length == 0)
						label = memberName.toMenuLabel;

					auto handler = makeAutomaticHandler!(__traits(getMember, T, memberName))(&__traits(getMember, t, memberName));

					auto action = new Action(label, correctIcon, handler);

					if(accelerator.keyString.length) {
						auto ke = KeyEvent.parse(accelerator.keyString);
						action.accelerator = ke;
						accelerators[ke.toStr] = handler;
					}

					if(toolbar !is .toolbar.init)
						toolbarActions ~= action;
					if(menu !is .menu.init) {
						Menu mc;
						if(menu.name in mcs) {
							mc = mcs[menu.name];
						} else {
							mc = new Menu(menu.name, this);
							menuBar.addItem(mc);
							mcs[menu.name] = mc;
						}

						if(separator)
							mc.addSeparator();
						mc.addItem(new MenuItem(action));
					}
				}
			}
		}

		this.menuBar = menuBar;

		if(toolbarActions.length) {
			auto tb = new ToolBar(toolbarActions, this);
		}
	}

	void delegate()[string] accelerators;

	override void defaultEventHandler_keydown(KeyDownEvent event) {
		auto str = event.originalKeyEvent.toStr;
		if(auto acl = str in accelerators)
			(*acl)();
		super.defaultEventHandler_keydown(event);
	}

	override void defaultEventHandler_mouseover(MouseOverEvent event) {
		super.defaultEventHandler_mouseover(event);
		if(this.statusBar !is null && event.target.statusTip.length)
			this.statusBar.parts[0].content = event.target.statusTip;
		else if(this.statusBar !is null && this.statusTip.length)
			this.statusBar.parts[0].content = this.statusTip; // ~ " " ~ event.target.toString();
	}

	override void addChild(Widget c, int position = int.max) {
		if(auto tb = cast(ToolBar) c)
			version(win32_widgets)
				super.addChild(c, 0);
			else version(custom_widgets)
				super.addChild(c, menuBar ? 1 : 0);
			else static assert(0);
		else
			clientArea.addChild(c, position);
	}

	ToolBar _toolBar;
	///
	ToolBar toolBar() { return _toolBar; }
	///
	ToolBar toolBar(ToolBar t) {
		_toolBar = t;
		foreach(child; this.children)
			if(child is t)
				return t;
		version(win32_widgets)
			super.addChild(t, 0);
		else version(custom_widgets)
			super.addChild(t, menuBar ? 1 : 0);
		else static assert(0);
		return t;
	}

	MenuBar _menu;
	///
	MenuBar menuBar() { return _menu; }
	///
	MenuBar menuBar(MenuBar m) {
		if(m is _menu) {
			version(custom_widgets)
				recomputeChildLayout();
			return m;
		}

		if(_menu !is null) {
			// make sure it is sanely removed
			// FIXME
		}

		_menu = m;

		version(win32_widgets) {
			SetMenu(parentWindow.win.impl.hwnd, m.handle);
		} else version(custom_widgets) {
			super.addChild(m, 0);

		//	clientArea.y = menu.height;
		//	clientArea.height = this.height - menu.height;

			recomputeChildLayout();
		} else static assert(false);

		return _menu;
	}
	private Widget _clientArea;
	///
	@property Widget clientArea() { return _clientArea; }
	protected @property void clientArea(Widget wid) {
		_clientArea = wid;
	}

	private StatusBar _statusBar;
	///
	@property StatusBar statusBar() { return _statusBar; }
	///
	@property void statusBar(StatusBar bar) {
		_statusBar = bar;
		super.addChild(_statusBar);
	}

	///
	@property string title() { return parentWindow.win.title; }
	///
	@property void title(string title) { parentWindow.win.title = title; }
}

/+
	This is really an implementation detail of [MainWindow]
+/
private class ClientAreaWidget : Widget {
	this() {
		this.tabStop = false;
		super(null);
		//sa = new ScrollableWidget(this);
	}
	/*
	ScrollableWidget sa;
	override void addChild(Widget w, int position) {
		if(sa is null)
			super.addChild(w, position);
		else {
			sa.addChild(w, position);
			sa.setContentSize(this.minWidth + 1, this.minHeight);
			import std.stdio; writeln(sa.contentWidth, "x", sa.contentHeight);
		}
	}
	*/
}

/**
	Toolbars are lists of buttons (typically icons) that appear under the menu.
	Each button ought to correspond to a menu item, represented by [Action] objects.
*/
class ToolBar : Widget {
	version(win32_widgets) {
		private const int idealHeight;
		override int minHeight() { return idealHeight; }
		override int maxHeight() { return idealHeight; }
	} else version(custom_widgets) {
		override int minHeight() { return toolbarIconSize; }// Window.lineHeight * 3/2; }
		override int maxHeight() { return toolbarIconSize; } //Window.lineHeight * 3/2; }
	} else static assert(false);
	override int heightStretchiness() { return 0; }

	version(win32_widgets) 
		HIMAGELIST imageList;

	this(Widget parent) {
		this(null, parent);
	}

	///
	this(Action[] actions, Widget parent) {
		super(parent);

		tabStop = false;

		version(win32_widgets) {
			// so i like how the flat thing looks on windows, but not on wine
			// and eh, with windows visual styles enabled it looks cool anyway soooo gonna
			// leave it commented
			createWin32Window(this, "ToolbarWindow32"w, "", TBSTYLE_LIST|/*TBSTYLE_FLAT|*/TBSTYLE_TOOLTIPS);
			
			SendMessageW(hwnd, TB_SETEXTENDEDSTYLE, 0, 8/*TBSTYLE_EX_MIXEDBUTTONS*/);

			imageList = ImageList_Create(
				// width, height
				16, 16,
				ILC_COLOR16 | ILC_MASK,
				16 /*numberOfButtons*/, 0);

			SendMessageW(hwnd, TB_SETIMAGELIST, cast(WPARAM) 0, cast(LPARAM) imageList);
			SendMessageW(hwnd, TB_LOADIMAGES, cast(WPARAM) IDB_STD_SMALL_COLOR, cast(LPARAM) HINST_COMMCTRL);
			SendMessageW(hwnd, TB_SETMAXTEXTROWS, 0, 0);
			SendMessageW(hwnd, TB_AUTOSIZE, 0, 0);

			TBBUTTON[] buttons;

			// FIXME: I_IMAGENONE is if here is no icon
			foreach(action; actions)
				buttons ~= TBBUTTON(
					MAKELONG(cast(ushort)(action.iconId ? (action.iconId - 1) : -2 /* I_IMAGENONE */), 0),
					action.id,
					TBSTATE_ENABLED, // state
					0, // style
					0, // reserved array, just zero it out
					0, // dwData
					cast(size_t) toWstringzInternal(action.label) // INT_PTR
				);

			SendMessageW(hwnd, TB_BUTTONSTRUCTSIZE, cast(WPARAM)TBBUTTON.sizeof, 0);
			SendMessageW(hwnd, TB_ADDBUTTONSW, cast(WPARAM) buttons.length, cast(LPARAM)buttons.ptr);

			SIZE size;
			import core.sys.windows.commctrl;
			SendMessageW(hwnd, TB_GETMAXSIZE, 0, cast(LPARAM) &size);
			idealHeight = size.cy + 4; // the plus 4 is a hack

			/*
			RECT rect;
			GetWindowRect(hwnd, &rect);
			idealHeight = rect.bottom - rect.top + 10; // the +10 is a hack since the size right now doesn't look right on a real Windows XP box
			*/

			assert(idealHeight);
		} else version(custom_widgets) {
			foreach(action; actions)
				new ToolButton(action, this);
		} else static assert(false);
	}

	override void recomputeChildLayout() {
		.recomputeChildLayout!"width"(this);
	}
}

enum toolbarIconSize = 24;

/// An implementation helper for [ToolBar]. Generally, you shouldn't create these yourself and instead just pass [Action]s to [ToolBar]'s constructor and let it create the buttons for you.
class ToolButton : Button {
	///
	this(string label, Widget parent) {
		super(label, parent);
		tabStop = false;
	}
	///
	this(Action action, Widget parent) {
		super(action.label, parent);
		tabStop = false;
		this.action = action;
	}

	version(custom_widgets)
	override void defaultEventHandler_click(ClickEvent event) {
		foreach(handler; action.triggered)
			handler();
	}

	Action action;

	override int maxWidth() { return toolbarIconSize; }
	override int minWidth() { return toolbarIconSize; }
	override int maxHeight() { return toolbarIconSize; }
	override int minHeight() { return toolbarIconSize; }

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
	painter.drawThemed(delegate Rectangle (const Rectangle bounds) {
		painter.outlineColor = Color.black;

		// I want to get from 16 to 24. that's * 3 / 2
		static assert(toolbarIconSize >= 16);
		enum multiplier = toolbarIconSize / 8;
		enum divisor = 2 + ((toolbarIconSize % 8) ? 1 : 0);
		switch(action.iconId) {
			case GenericIcons.New:
				painter.fillColor = Color.white;
				painter.drawPolygon(
					Point(3, 2) * multiplier / divisor, Point(3, 13) * multiplier / divisor, Point(12, 13) * multiplier / divisor, Point(12, 6) * multiplier / divisor,
					Point(8, 2) * multiplier / divisor, Point(8, 6) * multiplier / divisor, Point(12, 6) * multiplier / divisor, Point(8, 2) * multiplier / divisor,
					Point(3, 2) * multiplier / divisor, Point(3, 13) * multiplier / divisor
				);
			break;
			case GenericIcons.Save:
				painter.fillColor = Color.white;
				painter.outlineColor = Color.black;
				painter.drawRectangle(Point(2, 2) * multiplier / divisor, Point(13, 13) * multiplier / divisor);

				// the label
				painter.drawRectangle(Point(4, 8) * multiplier / divisor, Point(11, 13) * multiplier / divisor);

				// the slider
				painter.fillColor = Color.black;
				painter.outlineColor = Color.black;
				painter.drawRectangle(Point(4, 3) * multiplier / divisor, Point(10, 6) * multiplier / divisor);

				painter.fillColor = Color.white;
				painter.outlineColor = Color.white;
				// the disc window
				painter.drawRectangle(Point(5, 3) * multiplier / divisor, Point(6, 5) * multiplier / divisor);
			break;
			case GenericIcons.Open:
				painter.fillColor = Color.white;
				painter.drawPolygon(
					Point(4, 4) * multiplier / divisor, Point(4, 12) * multiplier / divisor, Point(13, 12) * multiplier / divisor, Point(13, 3) * multiplier / divisor,
					Point(9, 3) * multiplier / divisor, Point(9, 4) * multiplier / divisor, Point(4, 4) * multiplier / divisor);
				painter.drawPolygon(
					Point(2, 6) * multiplier / divisor, Point(11, 6) * multiplier / divisor,
					Point(12, 12) * multiplier / divisor, Point(4, 12) * multiplier / divisor,
					Point(2, 6) * multiplier / divisor);
				//painter.drawLine(Point(9, 6) * multiplier / divisor, Point(13, 7) * multiplier / divisor);
			break;
			case GenericIcons.Copy:
				painter.fillColor = Color.white;
				painter.drawRectangle(Point(3, 2) * multiplier / divisor, Point(9, 10) * multiplier / divisor);
				painter.drawRectangle(Point(6, 5) * multiplier / divisor, Point(12, 13) * multiplier / divisor);
			break;
			case GenericIcons.Cut:
				painter.fillColor = Color.transparent;
				painter.outlineColor = getComputedStyle.foregroundColor();
				painter.drawLine(Point(3, 2) * multiplier / divisor, Point(10, 9) * multiplier / divisor);
				painter.drawLine(Point(4, 9) * multiplier / divisor, Point(11, 2) * multiplier / divisor);
				painter.drawRectangle(Point(3, 9) * multiplier / divisor, Point(5, 13) * multiplier / divisor);
				painter.drawRectangle(Point(9, 9) * multiplier / divisor, Point(11, 12) * multiplier / divisor);
			break;
			case GenericIcons.Paste:
				painter.fillColor = Color.white;
				painter.drawRectangle(Point(2, 3) * multiplier / divisor, Point(11, 11) * multiplier / divisor);
				painter.drawRectangle(Point(6, 8) * multiplier / divisor, Point(13, 13) * multiplier / divisor);
				painter.drawLine(Point(6, 2) * multiplier / divisor, Point(4, 5) * multiplier / divisor);
				painter.drawLine(Point(6, 2) * multiplier / divisor, Point(9, 5) * multiplier / divisor);
				painter.fillColor = Color.black;
				painter.drawRectangle(Point(4, 5) * multiplier / divisor, Point(9, 6) * multiplier / divisor);
			break;
			case GenericIcons.Help:
				painter.outlineColor = getComputedStyle.foregroundColor();
				painter.drawText(Point(0, 0), "?", Point(width, height), TextAlignment.Center | TextAlignment.VerticalCenter);
			break;
			case GenericIcons.Undo:
				painter.fillColor = Color.transparent;
				painter.drawArc(Point(3, 4) * multiplier / divisor, 9 * multiplier / divisor, 9 * multiplier / divisor, 0, 360 * 64);
				painter.outlineColor = Color.black;
				painter.fillColor = Color.black;
				painter.drawPolygon(
					Point(4, 4) * multiplier / divisor,
					Point(8, 2) * multiplier / divisor,
					Point(8, 6) * multiplier / divisor,
					Point(4, 4) * multiplier / divisor,
				);
			break;
			case GenericIcons.Redo:
				painter.fillColor = Color.transparent;
				painter.drawArc(Point(3, 4) * multiplier / divisor, 9 * multiplier / divisor, 9 * multiplier / divisor, 0, 360 * 64);
				painter.outlineColor = Color.black;
				painter.fillColor = Color.black;
				painter.drawPolygon(
					Point(10, 4) * multiplier / divisor,
					Point(6, 2) * multiplier / divisor,
					Point(6, 6) * multiplier / divisor,
					Point(10, 4) * multiplier / divisor,
				);
			break;
			default:
				painter.drawText(Point(0, 0), action.label, Point(width, height), TextAlignment.Center | TextAlignment.VerticalCenter);
		}
		return bounds;
		});
	}

}


///
class MenuBar : Widget {
	MenuItem[] items;
	Menu[] subMenus;

	version(win32_widgets) {
		HMENU handle;
		///
		this(Widget parent = null) {
			super(parent);

			handle = CreateMenu();
			tabStop = false;
		}
	} else version(custom_widgets) {
		///
		this(Widget parent = null) {
			tabStop = false; // these are selected some other way
			super(parent);
		}

		mixin Padding!q{2};
	} else static assert(false);

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		draw3dFrame(this, painter, FrameStyle.risen, getComputedStyle().background.color);
	}

	///
	MenuItem addItem(MenuItem item) {
		this.addChild(item);
		items ~= item;
		version(win32_widgets) {
			AppendMenuW(handle, MF_STRING, item.action is null ? 9000 : item.action.id, toWstringzInternal(item.label));
		}
		return item;
	}


	///
	Menu addItem(Menu item) {

		subMenus ~= item;

		auto mbItem = new MenuItem(item.label, null);// this.parentWindow); // I'ma add the child down below so hopefully this isn't too insane

		addChild(mbItem);
		items ~= mbItem;

		version(win32_widgets) {
			AppendMenuW(handle, MF_STRING | MF_POPUP, cast(UINT) item.handle, toWstringzInternal(item.label));
		} else version(custom_widgets) {
			mbItem.defaultEventHandlers["mousedown"] = (Widget e, Event ev) {
				item.popup(mbItem);
			};
		} else static assert(false);

		return item;
	}

	override void recomputeChildLayout() {
		.recomputeChildLayout!"width"(this);
	}

	override int maxHeight() { return Window.lineHeight + 4; }
	override int minHeight() { return Window.lineHeight + 4; }
}


/**
	Status bars appear at the bottom of a MainWindow.
	They are made out of Parts, with a width and content.

	They can have multiple parts or be in simple mode. FIXME: implement


	sb.parts[0].content = "Status bar text!";
*/
class StatusBar : Widget {
	private Part[] partsArray;
	///
	struct Parts {
		@disable this();
		this(StatusBar owner) { this.owner = owner; }
		//@disable this(this);
		///
		@property int length() { return cast(int) owner.partsArray.length; }
		private StatusBar owner;
		private this(StatusBar owner, Part[] parts) {
			this.owner.partsArray = parts;
			this.owner = owner;
		}
		///
		Part opIndex(int p) {
			if(owner.partsArray.length == 0)
				this ~= new StatusBar.Part(300);
			return owner.partsArray[p];
		}

		///
		Part opOpAssign(string op : "~" )(Part p) {
			assert(owner.partsArray.length < 255);
			p.owner = this.owner;
			p.idx = cast(int) owner.partsArray.length;
			owner.partsArray ~= p;
			version(win32_widgets) {
				int[256] pos;
				int cpos = 0;
				foreach(idx, part; owner.partsArray) {
					if(part.width)
						cpos += part.width;
					else
						cpos += 100;

					if(idx + 1 == owner.partsArray.length)
						pos[idx] = -1;
					else
						pos[idx] = cpos;
				}
				SendMessageW(owner.hwnd, WM_USER + 4 /*SB_SETPARTS*/, owner.partsArray.length, cast(size_t) pos.ptr);
			} else version(custom_widgets) {
				owner.redraw();
			} else static assert(false);

			return p;
		}
	}

	private Parts _parts;
	///
	@property Parts parts() {
		return _parts;
	}

	///
	static class Part {
		int width;
		StatusBar owner;

		///
		this(int w = 100) { width = w; }

		private int idx;
		private string _content;
		///
		@property string content() { return _content; }
		///
		@property void content(string s) {
			version(win32_widgets) {
				_content = s;
				WCharzBuffer bfr = WCharzBuffer(s);
				SendMessageW(owner.hwnd, SB_SETTEXT, idx, cast(LPARAM) bfr.ptr);
			} else version(custom_widgets) {
				if(_content != s) {
					_content = s;
					owner.redraw();
				}
			} else static assert(false);
		}
	}
	string simpleModeContent;
	bool inSimpleMode;


	///
	this(Widget parent) {
		super(null); // FIXME
		_parts = Parts(this);
		tabStop = false;
		version(win32_widgets) {
			parentWindow = parent.parentWindow;
			createWin32Window(this, "msctls_statusbar32"w, "", 0);

			RECT rect;
			GetWindowRect(hwnd, &rect);
			idealHeight = rect.bottom - rect.top;
			assert(idealHeight);
		} else version(custom_widgets) {
		} else static assert(false);
	}

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		auto cs = getComputedStyle();
		this.draw3dFrame(painter, FrameStyle.sunk, cs.background.color);
		int cpos = 0;
		int remainingLength = this.width;
		foreach(idx, part; this.partsArray) {
			auto partWidth = part.width ? part.width : ((idx + 1 == this.partsArray.length) ? remainingLength : 100);
			painter.setClipRectangle(Point(cpos, 0), partWidth, height);
			draw3dFrame(cpos, 0, partWidth, height, painter, FrameStyle.sunk, cs.background.color);
			painter.setClipRectangle(Point(cpos + 2, 2), partWidth - 4, height - 4);

			painter.outlineColor = cs.foregroundColor();
			painter.fillColor = cs.foregroundColor();

			painter.drawText(Point(cpos + 4, 0), part.content, Point(width, height), TextAlignment.VerticalCenter);
			cpos += partWidth;
			remainingLength -= partWidth;
		}
	}


	version(win32_widgets) {
		private const int idealHeight;
		override int maxHeight() { return idealHeight; }
		override int minHeight() { return idealHeight; }
	} else version(custom_widgets) {
		override int maxHeight() { return Window.lineHeight + 4; }
		override int minHeight() { return Window.lineHeight + 4; }
	} else static assert(false);
}

/// Displays an in-progress indicator without known values
version(none)
class IndefiniteProgressBar : Widget {
	version(win32_widgets)
	this(Widget parent) {
		super(parent);
		createWin32Window(this, "msctls_progress32"w, "", 8 /* PBS_MARQUEE */);
		tabStop = false;
	}
	override int minHeight() { return 10; }
}

/// A progress bar with a known endpoint and completion amount
class ProgressBar : Widget {
	this(Widget parent) {
		version(win32_widgets) {
			super(parent);
			createWin32Window(this, "msctls_progress32"w, "", 0);
			tabStop = false;
		} else version(custom_widgets) {
			super(parent);
			max = 100;
			step = 10;
			tabStop = false;
		} else static assert(0);
	}

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		auto cs = getComputedStyle();
		this.draw3dFrame(painter, FrameStyle.sunk, cs.background.color);
		painter.fillColor = cs.progressBarColor;
		painter.drawRectangle(Point(0, 0), width * current / max, height);
	}


	version(custom_widgets) {
		int current;
		int max;
		int step;
	}

	///
	void advanceOneStep() {
		version(win32_widgets)
			SendMessageW(hwnd, PBM_STEPIT, 0, 0);
		else version(custom_widgets)
			addToPosition(step);
		else static assert(false);
	}

	///
	void setStepIncrement(int increment) {
		version(win32_widgets)
			SendMessageW(hwnd, PBM_SETSTEP, increment, 0);
		else version(custom_widgets)
			step = increment;
		else static assert(false);
	}

	///
	void addToPosition(int amount) {
		version(win32_widgets)
			SendMessageW(hwnd, PBM_DELTAPOS, amount, 0);
		else version(custom_widgets)
			setPosition(current + amount);
		else static assert(false);
	}

	///
	void setPosition(int pos) {
		version(win32_widgets)
			SendMessageW(hwnd, PBM_SETPOS, pos, 0);
		else version(custom_widgets) {
			current = pos;
			if(current > max)
				current = max;
			redraw();
		}
		else static assert(false);
	}

	///
	void setRange(ushort min, ushort max) {
		version(win32_widgets)
			SendMessageW(hwnd, PBM_SETRANGE, 0, MAKELONG(min, max));
		else version(custom_widgets) {
			this.max = max;
		}
		else static assert(false);
	}

	override int minHeight() { return 10; }
}

///
class Fieldset : Widget {
	// FIXME: on Windows,it doesn't draw the background on the label
	// on X, it doesn't fix the clipping rectangle for it
	version(win32_widgets)
		override int paddingTop() { return Window.lineHeight; }
	else version(custom_widgets)
		override int paddingTop() { return Window.lineHeight + 2; }
	else static assert(false);
	override int paddingBottom() { return 6; }
	override int paddingLeft() { return 6; }
	override int paddingRight() { return 6; }

	override int marginLeft() { return 6; }
	override int marginRight() { return 6; }
	override int marginTop() { return 2; }
	override int marginBottom() { return 2; }

	string legend;

	///
	this(string legend, Widget parent) {
		version(win32_widgets) {
			super(parent);
			this.legend = legend;
			createWin32Window(this, "button"w, legend, BS_GROUPBOX);
			tabStop = false;
		} else version(custom_widgets) {
			super(parent);
			tabStop = false;
			this.legend = legend;
		} else static assert(0);
	}

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		painter.fillColor = Color.transparent;
		auto cs = getComputedStyle();
		painter.pen = Pen(cs.foregroundColor, 1);
		painter.drawRectangle(Point(0, Window.lineHeight / 2), width, height - Window.lineHeight / 2);

		auto tx = painter.textSize(legend);
		painter.outlineColor = Color.transparent;

		static if(UsingSimpledisplayX11) {
			painter.fillColor = getComputedStyle().windowBackgroundColor;
			painter.drawRectangle(Point(8, 0), tx.width, tx.height);
		} else version(Windows) {
			auto b = SelectObject(painter.impl.hdc, GetSysColorBrush(COLOR_3DFACE));
			painter.drawRectangle(Point(8, -tx.height/2), tx.width, tx.height);
			SelectObject(painter.impl.hdc, b);
		} else static assert(0);
		painter.outlineColor = cs.foregroundColor;
		painter.drawText(Point(8, 0), legend);
	}


	override int maxHeight() {
		auto m = paddingTop() + paddingBottom();
		foreach(child; children) {
			auto mh = child.maxHeight();
			if(mh == int.max)
				return int.max;
			m += mh;
			m += child.marginBottom();
			m += child.marginTop();
		}
		m += 6;
		if(m < minHeight)
			return minHeight;
		return m;
	}

	override int minHeight() {
		auto m = paddingTop() + paddingBottom();
		foreach(child; children) {
			m += child.minHeight();
			m += child.marginBottom();
			m += child.marginTop();
		}
		return m + 6;
	}
}

/// Draws a line
class HorizontalRule : Widget {
	mixin Margin!q{ 2 };
	override int minHeight() { return 2; }
	override int maxHeight() { return 2; }

	///
	this(Widget parent) {
		super(parent);
	}

	override void paint(WidgetPainter painter) {
		auto cs = getComputedStyle();
		painter.outlineColor = cs.darkAccentColor;
		painter.drawLine(Point(0, 0), Point(width, 0));
		painter.outlineColor = cs.lightAccentColor;
		painter.drawLine(Point(0, 1), Point(width, 1));
	}
}

/// ditto
class VerticalRule : Widget {
	mixin Margin!q{ 2 };
	override int minWidth() { return 2; }
	override int maxWidth() { return 2; }

	///
	this(Widget parent) {
		super(parent);
	}

	override void paint(WidgetPainter painter) {
		auto cs = getComputedStyle();
		painter.outlineColor = cs.darkAccentColor;
		painter.drawLine(Point(0, 0), Point(0, height));
		painter.outlineColor = cs.lightAccentColor;
		painter.drawLine(Point(1, 0), Point(1, height));
	}
}


///
class Menu : Window {
	void remove() {
		foreach(i, child; parentWindow.children)
			if(child is this) {
				parentWindow._children = parentWindow._children[0 .. i] ~ parentWindow._children[i + 1 .. $];
				break;
			}
		parentWindow.redraw();

		parentWindow.releaseMouseCapture();
	}

	///
	void addSeparator() {
		version(win32_widgets)
			AppendMenu(handle, MF_SEPARATOR, 0, null);
		else version(custom_widgets)
			auto hr = new HorizontalRule(this);
		else static assert(0);
	}

	override int paddingTop() { return 4; }
	override int paddingBottom() { return 4; }
	override int paddingLeft() { return 2; }
	override int paddingRight() { return 2; }

	version(win32_widgets) {}
	else version(custom_widgets) {
		SimpleWindow dropDown;
		Widget menuParent;
		void popup(Widget parent, int offsetX = 0, int offsetY = int.min) {
			this.menuParent = parent;

			int w = 150;
			int h = paddingTop + paddingBottom;
			if(this.children.length) {
				// hacking it to get the ideal height out of recomputeChildLayout
				this.width = w;
				this.height = h;
				this.recomputeChildLayout();
				h = this.children[$-1].y + this.children[$-1].height + this.children[$-1].marginBottom;
				h += paddingBottom;

				h -= 2; // total hack, i just like the way it looks a bit tighter even though technically MenuItem reserves some space to center in normal circumstances
			}

			if(offsetY == int.min)
				offsetY = parent.parentWindow.lineHeight;

			auto coord = parent.globalCoordinates();
			dropDown.moveResize(coord.x + offsetX, coord.y + offsetY, w, h);
			this.x = 0;
			this.y = 0;
			this.width = dropDown.width;
			this.height = dropDown.height;
			this.drawableWindow = dropDown;
			this.recomputeChildLayout();

			static if(UsingSimpledisplayX11)
				XSync(XDisplayConnection.get, 0);

			dropDown.visibilityChanged = (bool visible) {
				if(visible) {
					this.redraw();
					dropDown.grabInput();
				} else {
					dropDown.releaseInputGrab();
				}
			};

			dropDown.show();

			bool firstClick = true;

			clickListener = this.addEventListener(EventType.click, (Event ev) {
				if(firstClick) {
					firstClick = false;
					//return;
				}
				//if(ev.clientX < 0 || ev.clientY < 0 || ev.clientX > width || ev.clientY > height)
					unpopup();
			});
		}

		EventListener clickListener;
	}
	else static assert(false);

	version(custom_widgets)
	void unpopup() {
		mouseLastOver = mouseLastDownOn = null;
		dropDown.hide();
		if(!menuParent.parentWindow.win.closed) {
			if(auto maw = cast(MouseActivatedWidget) menuParent) {
				maw.setDynamicState(DynamicState.depressed, false);
				maw.redraw();
			}
			menuParent.parentWindow.win.focus();
		}
		clickListener.disconnect();
	}

	MenuItem[] items;

	///
	MenuItem addItem(MenuItem item) {
		addChild(item);
		items ~= item;
		version(win32_widgets) {
			AppendMenuW(handle, MF_STRING, item.action is null ? 9000 : item.action.id, toWstringzInternal(item.label));
		}
		return item;
	}

	string label;

	version(win32_widgets) {
		HMENU handle;
		///
		this(string label, Widget parent) {
			// not actually passing the parent since it effs up the drawing
			super(cast(Widget) null);// parent);
			this.label = label;
			handle = CreatePopupMenu();
		}
	} else version(custom_widgets) {
		///
		this(string label, Widget parent) {

			if(dropDown) {
				dropDown.close();
			}
			dropDown = new SimpleWindow(
				150, 4,
				null, OpenGlOptions.no, Resizability.fixedSize, WindowTypes.dropdownMenu, WindowFlags.dontAutoShow, parent ? parent.parentWindow.win : null);

			this.label = label;

			super(dropDown);
		}
	} else static assert(false);

	override int maxHeight() { return Window.lineHeight; }
	override int minHeight() { return Window.lineHeight; }

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		this.draw3dFrame(painter, FrameStyle.risen, getComputedStyle.background.color);
	}
}

/++
	A MenuItem belongs to a [Menu] - use [Menu.addItem] to add one - and calls an [Action] when it is clicked.
+/
class MenuItem : MouseActivatedWidget {
	Menu submenu;

	Action action;
	string label;

	override int paddingLeft() { return 4; }

	override int maxHeight() { return Window.lineHeight + 4; }
	override int minHeight() { return Window.lineHeight + 4; }
	override int minWidth() { return Window.lineHeight * cast(int) label.length + 8; }
	override int maxWidth() {
		if(cast(MenuBar) parent) {
			return Window.lineHeight / 2 * cast(int) label.length + 8;
		}
		return int.max;
	}
	/// This should ONLY be used if there is no associated action, for example, if the menu item is just a submenu.
	this(string lbl, Widget parent = null) {
		super(parent);
		//label = lbl; // FIXME
		foreach(char ch; lbl) // FIXME
			if(ch != '&') // FIXME
				label ~= ch; // FIXME
		tabStop = false; // these are selected some other way
	}

	///
	this(Action action, Widget parent = null) {
		assert(action !is null);
		this(action.label, parent);
		this.action = action;
		tabStop = false; // these are selected some other way
	}

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		auto cs = getComputedStyle();
		if(dynamicState & DynamicState.depressed)
			this.draw3dFrame(painter, FrameStyle.sunk, cs.background.color);
		if(dynamicState & DynamicState.hover)
			painter.outlineColor = cs.activeMenuItemColor;
		else
			painter.outlineColor = cs.foregroundColor;
		painter.fillColor = Color.transparent;
		painter.drawText(Point(cast(MenuBar) this.parent ? 4 : 20, 2), label, Point(width, height), TextAlignment.Left);
		if(action && action.accelerator !is KeyEvent.init) {
			painter.drawText(Point(cast(MenuBar) this.parent ? 4 : 20, 2), action.accelerator.toStr(), Point(width - 4, height), TextAlignment.Right);

		}
	}

	override void defaultEventHandler_triggered(Event event) {
		if(action)
		foreach(handler; action.triggered)
			handler();

		if(auto pmenu = cast(Menu) this.parent)
			pmenu.remove();

		super.defaultEventHandler_triggered(event);
	}
}

version(win32_widgets)
/// A "mouse activiated widget" is really just an abstract variant of button.
class MouseActivatedWidget : Widget {
	@property bool isChecked() {
		assert(hwnd);
		return SendMessageW(hwnd, BM_GETCHECK, 0, 0) == BST_CHECKED;

	}
	@property void isChecked(bool state) {
		assert(hwnd);
		SendMessageW(hwnd, BM_SETCHECK, state ? BST_CHECKED : BST_UNCHECKED, 0);

	}

	override void handleWmCommand(ushort cmd, ushort id) {
		if(cmd == 0) {
			auto event = new Event(EventType.triggered, this);
			event.dispatch();
		}
	}

	this(Widget parent) {
		super(parent);
	}
}
else version(custom_widgets)
/// ditto
class MouseActivatedWidget : Widget {
	@property bool isChecked() { return isChecked_; }
	@property bool isChecked(bool b) { return isChecked_ = b; }

	private bool isChecked_;

	this(Widget parent) {
		super(parent);

		addEventListener((MouseDownEvent ev) {
			if(ev.button == MouseButton.left) {
				setDynamicState(DynamicState.depressed, true);
				setDynamicState(DynamicState.hover, true);
				redraw();
			}
		});

		addEventListener((MouseUpEvent ev) {
			if(ev.button == MouseButton.left) {
				setDynamicState(DynamicState.depressed, false);
				setDynamicState(DynamicState.hover, false);
				redraw();
			}
		});

		addEventListener((MouseMoveEvent mme) {
			if(!(mme.state & ModifierState.leftButtonDown)) {
				setDynamicState(DynamicState.depressed, false);
				redraw();
			}
		});
	}

	override void defaultEventHandler_focus(Event ev) {
		super.defaultEventHandler_focus(ev);
		this.redraw();
	}
	override void defaultEventHandler_blur(Event ev) {
		super.defaultEventHandler_blur(ev);
		setDynamicState(DynamicState.depressed, false);
		this.redraw();
	}
	override void defaultEventHandler_keydown(KeyDownEvent ev) {
		super.defaultEventHandler_keydown(ev);
		if(ev.key == Key.Space || ev.key == Key.Enter || ev.key == Key.PadEnter) {
			setDynamicState(DynamicState.depressed, true);
			setDynamicState(DynamicState.hover, true);
			this.redraw();
		}
	}
	override void defaultEventHandler_keyup(KeyUpEvent ev) {
		super.defaultEventHandler_keyup(ev);
		if(!(dynamicState & DynamicState.depressed))
			return;
		setDynamicState(DynamicState.depressed, false);
		setDynamicState(DynamicState.hover, false);
		this.redraw();

		auto event = new Event(EventType.triggered, this);
		event.sendDirectly();
	}
	override void defaultEventHandler_click(ClickEvent ev) {
		super.defaultEventHandler_click(ev);
		if(ev.button == MouseButton.left) {
			auto event = new Event(EventType.triggered, this);
			event.sendDirectly();
		}
	}

}
else static assert(false);

/*
/++
	Like the tablet thing, it would have a label, a description, and a switch slider thingy.

	Basically the same as a checkbox.
+/
class OnOffSwitch : MouseActivatedWidget {

}
*/

/++
	A basic checked or not checked box with an attached label.
+/
class Checkbox : MouseActivatedWidget {
	version(win32_widgets) {
		override int maxHeight() { return 16; }
		override int minHeight() { return 16; }
	} else version(custom_widgets) {
		override int maxHeight() { return Window.lineHeight; }
		override int minHeight() { return Window.lineHeight; }
	} else static assert(0);

	override int marginLeft() { return 4; }

	/++
		Just an alias because I keep typing checked out of web habit.

		History:
			Added May 31, 2021
	+/
	alias checked = isChecked;

	private string label;

	///
	this(string label, Widget parent) {
		super(parent);
		this.label = label;
		version(win32_widgets) {
			createWin32Window(this, "button"w, label, BS_CHECKBOX);
		} else version(custom_widgets) {

		} else static assert(0);
	}

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		auto cs = getComputedStyle();
		if(isFocused()) {
			painter.pen = Pen(Color.black, 1, Pen.Style.Dotted);
			painter.fillColor = cs.windowBackgroundColor;
			painter.drawRectangle(Point(0, 0), width, height);
			painter.pen = Pen(Color.black, 1, Pen.Style.Solid);
		} else {
			painter.pen = Pen(cs.windowBackgroundColor, 1, Pen.Style.Solid);
			painter.fillColor = cs.windowBackgroundColor;
			painter.drawRectangle(Point(0, 0), width, height);
		}


		enum buttonSize = 16;

		painter.outlineColor = Color.black;
		painter.fillColor = Color.white;
		painter.drawRectangle(Point(2, 2), buttonSize - 2, buttonSize - 2);

		if(isChecked) {
			painter.pen = Pen(Color.black, 2);
			// I'm using height so the checkbox is square
			enum padding = 5;
			painter.drawLine(Point(padding, padding), Point(buttonSize - (padding-2), buttonSize - (padding-2)));
			painter.drawLine(Point(buttonSize-(padding-2), padding), Point(padding, buttonSize - (padding-2)));

			painter.pen = Pen(Color.black, 1);
		}

		if(label !is null) {
			painter.outlineColor = cs.foregroundColor();
			painter.fillColor = cs.foregroundColor();

			// FIXME: should prolly just align the baseline or something
			painter.drawText(Point(buttonSize + 4, 2), label, Point(width, height), TextAlignment.Left | TextAlignment.VerticalCenter);
		}
	}

	override void defaultEventHandler_triggered(Event ev) {
		isChecked = !isChecked;

		this.emit!(ChangeEvent!bool)(&isChecked);

		redraw();
	}

	/// Emits a change event with the checked state
	mixin Emits!(ChangeEvent!bool);
}

/// Adds empty space to a layout.
class VerticalSpacer : Widget {
	///
	this(Widget parent) {
		super(parent);
	}
}

/// ditto
class HorizontalSpacer : Widget {
	///
	this(Widget parent) {
		super(parent);
		this.tabStop = false;
	}
}


///
class Radiobox : MouseActivatedWidget {

	version(win32_widgets) {
		override int maxHeight() { return 16; }
		override int minHeight() { return 16; }
	} else version(custom_widgets) {
		override int maxHeight() { return Window.lineHeight; }
		override int minHeight() { return Window.lineHeight; }
	} else static assert(0);

	override int marginLeft() { return 4; }

	private string label;

	version(win32_widgets)
	this(string label, Widget parent) {
		super(parent);
		this.label = label;
		createWin32Window(this, "button"w, label, BS_AUTORADIOBUTTON);
	}
	else version(custom_widgets)
	this(string label, Widget parent) {
		super(parent);
		this.label = label;
		height = 16;
		width = height + 4 + cast(int) label.length * 16;
	}
	else static assert(false);

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		auto cs = getComputedStyle();
		if(isFocused) {
			painter.fillColor = cs.windowBackgroundColor;
			painter.pen = Pen(Color.black, 1, Pen.Style.Dotted);
		} else {
			painter.fillColor = cs.windowBackgroundColor;
			painter.outlineColor = cs.windowBackgroundColor;
		}
		painter.drawRectangle(Point(0, 0), width, height);

		painter.pen = Pen(Color.black, 1, Pen.Style.Solid);

		enum buttonSize = 16;

		painter.outlineColor = Color.black;
		painter.fillColor = Color.white;
		painter.drawEllipse(Point(2, 2), Point(buttonSize - 2, buttonSize - 2));
		if(isChecked) {
			painter.outlineColor = Color.black;
			painter.fillColor = Color.black;
			// I'm using height so the checkbox is square
			painter.drawEllipse(Point(5, 5), Point(buttonSize - 5, buttonSize - 5));
		}

		painter.outlineColor = cs.foregroundColor();
		painter.fillColor = cs.foregroundColor();

		painter.drawText(Point(buttonSize + 4, 0), label, Point(width, height), TextAlignment.Left | TextAlignment.VerticalCenter);
	}


	override void defaultEventHandler_triggered(Event ev) {
		isChecked = true;

		if(this.parent) {
			foreach(child; this.parent.children) {
				if(child is this) continue;
				if(auto rb = cast(Radiobox) child) {
					rb.isChecked = false;
					rb.emit!(ChangeEvent!bool)(&rb.isChecked);
					rb.redraw();
				}
			}
		}

		this.emit!(ChangeEvent!bool)(&this.isChecked);

		redraw();
	}

	/// Emits a change event with if it is checked. Note that when you select one in a group, that one will emit changed with value == true, and the previous one will emit changed with value == false right before. A button group may catch this and change the event.
	mixin Emits!(ChangeEvent!bool);
}


///
class Button : MouseActivatedWidget {
	override int heightStretchiness() { return 3; }
	override int widthStretchiness() { return 3; }

	private string label_;

	///
	string label() { return label_; }
	///
	void label(string l) {
		label_ = l;
		version(win32_widgets) {
			WCharzBuffer bfr = WCharzBuffer(l);
			SetWindowTextW(hwnd, bfr.ptr);
		} else version(custom_widgets) {
			redraw();
		}
	}

	version(win32_widgets)
	this(string label, Widget parent) {
		// FIXME: use ideal button size instead
		width = 50;
		height = 30;
		super(parent);
		createWin32Window(this, "button"w, label, BS_PUSHBUTTON);

		this.label = label;
	}
	else version(custom_widgets)
	this(string label, Widget parent) {
		width = 50;
		height = 30;
		super(parent);

		this.label = label;
	}
	else static assert(false);

	override int minHeight() { return Window.lineHeight + 4; }

	static class Style : Widget.Style {
		override WidgetBackground background() {
			auto cs = widget.getComputedStyle(); // FIXME: this is potentially recursive

			auto pressed = DynamicState.depressed | DynamicState.hover;
			if((widget.dynamicState & pressed) == pressed) {
				return WidgetBackground(cs.depressedButtonColor());
			} else if(widget.dynamicState & DynamicState.hover) {
				return WidgetBackground(cs.hoveringColor());
			} else {
				return WidgetBackground(cs.buttonColor());
			}
		}

		override FrameStyle borderStyle() {
			auto pressed = DynamicState.depressed | DynamicState.hover;
			if((widget.dynamicState & pressed) == pressed) {
				return FrameStyle.sunk;
			} else {
				return FrameStyle.risen;
			}

		}
	}
	mixin OverrideStyle!Style;

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		painter.drawThemed(delegate Rectangle(const Rectangle bounds) {
			painter.drawText(bounds.upperLeft, label, bounds.lowerRight, TextAlignment.Center | TextAlignment.VerticalCenter);
			return bounds;
		});
	}

}

/++
	A button with a consistent size, suitable for user commands like OK and Cancel.
+/
class CommandButton : Button {
	this(string label, Widget parent) {
		super(label, parent);
	}

	override int maxHeight() {
		return Window.lineHeight + 4;
	}

	override int maxWidth() {
		return Window.lineHeight * 4;
	}

	override int marginLeft() { return 12; }
	override int marginRight() { return 12; }
	override int marginTop() { return 12; }
	override int marginBottom() { return 12; }
}

///
enum ArrowDirection {
	left, ///
	right, ///
	up, ///
	down ///
}

///
version(custom_widgets)
class ArrowButton : Button {
	///
	this(ArrowDirection direction, Widget parent) {
		super("", parent);
		this.direction = direction;
	}

	private ArrowDirection direction;

	override int minHeight() { return 16; }
	override int maxHeight() { return 16; }
	override int minWidth() { return 16; }
	override int maxWidth() { return 16; }

	override void paint(WidgetPainter painter) {
		super.paint(painter);

		auto cs = getComputedStyle();

		painter.outlineColor = cs.foregroundColor;
		painter.fillColor = cs.foregroundColor;

		auto offset = Point((this.width - 16) / 2, (this.height - 16) / 2);

		final switch(direction) {
			case ArrowDirection.up:
				painter.drawPolygon(
					Point(2, 10) + offset,
					Point(7, 5) + offset,
					Point(12, 10) + offset,
					Point(2, 10) + offset
				);
			break;
			case ArrowDirection.down:
				painter.drawPolygon(
					Point(2, 6) + offset,
					Point(7, 11) + offset,
					Point(12, 6) + offset,
					Point(2, 6) + offset
				);
			break;
			case ArrowDirection.left:
				painter.drawPolygon(
					Point(10, 2) + offset,
					Point(5, 7) + offset,
					Point(10, 12) + offset,
					Point(10, 2) + offset
				);
			break;
			case ArrowDirection.right:
				painter.drawPolygon(
					Point(6, 2) + offset,
					Point(11, 7) + offset,
					Point(6, 12) + offset,
					Point(6, 2) + offset
				);
			break;
		}
	}
}

private
int[2] getChildPositionRelativeToParentOrigin(Widget c) nothrow {
	int x, y;
	Widget par = c;
	while(par) {
		x += par.x;
		y += par.y;
		par = par.parent;
	}
	return [x, y];
}

version(win32_widgets)
private
int[2] getChildPositionRelativeToParentHwnd(Widget c) nothrow {
	int x, y;
	Widget par = c;
	while(par) {
		x += par.x;
		y += par.y;
		par = par.parent;
		if(par !is null && par.useNativeDrawing())
			break;
	}
	return [x, y];
}

///
class ImageBox : Widget {
	private MemoryImage image_;

	///
	public void setImage(MemoryImage image){
		this.image_ = image;
		if(this.parentWindow && this.parentWindow.win)
			sprite = new Sprite(this.parentWindow.win, Image.fromMemoryImage(image_));
		redraw();
	}

	/// How to fit the image in the box if they aren't an exact match in size?
	enum HowToFit {
		center, /// centers the image, cropping around all the edges as needed
		crop, /// always draws the image in the upper left, cropping the lower right if needed
		// stretch, /// not implemented
	}

	private Sprite sprite;
	private HowToFit howToFit_;

	private Color backgroundColor_;

	///
	this(MemoryImage image, HowToFit howToFit, Color backgroundColor, Widget parent) {
		this.image_ = image;
		this.tabStop = false;
		this.howToFit_ = howToFit;
		this.backgroundColor_ = backgroundColor;
		super(parent);
		updateSprite();
	}

	/// ditto
	this(MemoryImage image, HowToFit howToFit, Widget parent) {
		this(image, howToFit, Color.transparent, parent);
	}

	private void updateSprite() {
		if(sprite is null && this.parentWindow && this.parentWindow.win) {
			sprite = new Sprite(this.parentWindow.win, Image.fromMemoryImage(image_));
		}
	}

	override void paint(WidgetPainter painter) {
		updateSprite();
		if(backgroundColor_.a) {
			painter.fillColor = backgroundColor_;
			painter.drawRectangle(Point(0, 0), width, height);
		}
		if(howToFit_ == HowToFit.crop)
			sprite.drawAt(painter, Point(0, 0));
		else if(howToFit_ == HowToFit.center) {
			sprite.drawAt(painter, Point((width - image_.width) / 2, (height - image_.height) / 2));
		}
	}
}

///
class TextLabel : Widget {
	override int maxHeight() { return Window.lineHeight; }
	override int minHeight() { return Window.lineHeight; }
	override int minWidth() { return 32; }

	string label_;

	///
	@scriptable
	string label() { return label_; }

	///
	@scriptable
	void label(string l) {
		label_ = l;
		version(win32_widgets) {
			WCharzBuffer bfr = WCharzBuffer(l);
			SetWindowTextW(hwnd, bfr.ptr);
		} else version(custom_widgets)
			redraw();
	}

	///
	this(string label, Widget parent) {
		this(label, TextAlignment.Right, parent);
	}

	///
	this(string label, TextAlignment alignment, Widget parent) {
		this.label_ = label;
		this.alignment = alignment;
		this.tabStop = false;
		super(parent);

		version(win32_widgets)
		createWin32Window(this, "static"w, label, alignment == TextAlignment.Center ? SS_CENTER : 0, alignment == TextAlignment.Right ? WS_EX_RIGHT : WS_EX_LEFT);
	}

	TextAlignment alignment;

	version(custom_widgets)
	override void paint(WidgetPainter painter) {
		painter.outlineColor = getComputedStyle().foregroundColor;
		painter.drawText(Point(0, 0), this.label, Point(width, height), alignment);
	}

}

version(custom_widgets)
	private struct etc {
		mixin ExperimentalTextComponent;
	}

version(win32_widgets)
	alias EditableTextWidgetParent = Widget; ///
else version(custom_widgets)
	alias EditableTextWidgetParent = ScrollableWidget; ///
else static assert(0);

/// Contains the implementation of text editing
abstract class EditableTextWidget : EditableTextWidgetParent {
	this(Widget parent) {
		super(parent);
	}

	bool wordWrapEnabled_ = false;
	void wordWrapEnabled(bool enabled) {
		version(win32_widgets) {
			SendMessageW(hwnd, EM_FMTLINES, enabled ? 1 : 0, 0);
		} else version(custom_widgets) {
			wordWrapEnabled_ = enabled; // FIXME
		} else static assert(false);
	}

	override int minWidth() { return 16; }
	override int minHeight() { return Window.lineHeight + 0; } // the +0 is to leave room for the padding
	override int widthStretchiness() { return 7; }

	void selectAll() {
		version(win32_widgets)
			SendMessage(hwnd, EM_SETSEL, 0, -1);
		else version(custom_widgets) {
			textLayout.selectAll();
			redraw();
		}
	}

	@property string content() {
		version(win32_widgets) {
			wchar[4096] bufferstack;
			wchar[] buffer;
			auto len = GetWindowTextLength(hwnd);
			if(len < bufferstack.length)
				buffer = bufferstack[0 .. len + 1];
			else
				buffer = new wchar[](len + 1);

			auto l = GetWindowTextW(hwnd, buffer.ptr, cast(int) buffer.length);
			if(l >= 0)
				return makeUtf8StringFromWindowsString(buffer[0 .. l]);
			else
				return null;
		} else version(custom_widgets) {
			return textLayout.getPlainText();
		} else static assert(false);
	}
	@property void content(string s) {
		version(win32_widgets) {
			WCharzBuffer bfr = WCharzBuffer(s, WindowsStringConversionFlags.convertNewLines);
			SetWindowTextW(hwnd, bfr.ptr);
		} else version(custom_widgets) {
			textLayout.clear();
			textLayout.addText(s);

			{
			// FIXME: it should be able to get this info easier
			auto painter = draw();
			textLayout.redoLayout(painter);
			}
			auto cbb = textLayout.contentBoundingBox();
			setContentSize(cbb.width, cbb.height);
			/*
			textLayout.addText(ForegroundColor.red, s);
			textLayout.addText(ForegroundColor.blue, TextFormat.underline, "http://dpldocs.info/");
			textLayout.addText(" is the best!");
			*/
			redraw();
		}
		else static assert(false);
	}

	void addText(string txt) {
		version(custom_widgets) {

			textLayout.addText(txt);

			{
			// FIXME: it should be able to get this info easier
			auto painter = draw();
			textLayout.redoLayout(painter);
			}
			auto cbb = textLayout.contentBoundingBox();
			setContentSize(cbb.width, cbb.height);

		} else version(win32_widgets) {
			// get the current selection
			DWORD StartPos, EndPos;
			SendMessageW( hwnd, EM_GETSEL, cast(WPARAM)(&StartPos), cast(LPARAM)(&EndPos) );

			// move the caret to the end of the text
			int outLength = GetWindowTextLengthW(hwnd);
			SendMessageW( hwnd, EM_SETSEL, outLength, outLength );

			// insert the text at the new caret position
			WCharzBuffer bfr = WCharzBuffer(txt, WindowsStringConversionFlags.convertNewLines);
			SendMessageW( hwnd, EM_REPLACESEL, TRUE, cast(LPARAM) bfr.ptr );

			// restore the previous selection
			SendMessageW( hwnd, EM_SETSEL, StartPos, EndPos );
		} else static assert(0);
	}

	version(custom_widgets)
	override void paintFrameAndBackground(WidgetPainter painter) {
		this.draw3dFrame(painter, FrameStyle.sunk, Color.white);
	}

	version(win32_widgets) { /* will do it with Windows calls in the classes */ }
	else version(custom_widgets) {
		// FIXME

		static if(SimpledisplayTimerAvailable)
			Timer caretTimer;
		etc.TextLayout textLayout;

		void setupCustomTextEditing() {
			textLayout = new etc.TextLayout(Rectangle(4, 2, width - 8, height - 4));
			textLayout.selectionXorColor = getComputedStyle().activeListXorColor;
		}

		override void paint(WidgetPainter painter) {
			if(parentWindow.win.closed) return;

			textLayout.boundingBox = Rectangle(4, 2, width - 8, height - 4);

			/*
			painter.outlineColor = Color.white;
			painter.fillColor = Color.white;
			painter.drawRectangle(Point(4, 4), contentWidth, contentHeight);
			*/

			painter.outlineColor = Color.black;
			// painter.drawText(Point(4, 4), content, Point(width - 4, height - 4));

			textLayout.caretShowingOnScreen = false;

			textLayout.drawInto(painter, !parentWindow.win.closed && isFocused());
		}

		static class Style : Widget.Style {
			override MouseCursor cursor() {
				return GenericCursor.Text;
			}
		}
		mixin OverrideStyle!Style;
	}
	else static assert(false);



	version(custom_widgets)
	override void defaultEventHandler_mousedown(MouseDownEvent ev) {
		super.defaultEventHandler_mousedown(ev);
		if(parentWindow.win.closed) return;
		if(ev.button == MouseButton.left) {
			if(textLayout.selectNone())
				redraw();
			textLayout.moveCaretToPixelCoordinates(ev.clientX, ev.clientY);
			this.focus();
			//this.parentWindow.win.grabInput();
		} else if(ev.button == MouseButton.middle) {
			static if(UsingSimpledisplayX11) {
				getPrimarySelection(parentWindow.win, (txt) {
					textLayout.insert(txt);
					redraw();

					auto cbb = textLayout.contentBoundingBox();
					setContentSize(cbb.width, cbb.height);
				});
			}
		}
	}

	version(custom_widgets)
	override void defaultEventHandler_mouseup(MouseUpEvent ev) {
		//this.parentWindow.win.releaseInputGrab();
		super.defaultEventHandler_mouseup(ev);
	}

	version(custom_widgets)
	override void defaultEventHandler_mousemove(MouseMoveEvent ev) {
		super.defaultEventHandler_mousemove(ev);
		if(ev.state & ModifierState.leftButtonDown) {
			textLayout.selectToPixelCoordinates(ev.clientX, ev.clientY);
			redraw();
		}
	}

	version(custom_widgets)
	override void defaultEventHandler_focus(Event ev) {
		super.defaultEventHandler_focus(ev);
		if(parentWindow.win.closed) return;
		auto painter = this.draw();
		textLayout.drawCaret(painter);

		static if(SimpledisplayTimerAvailable)
		if(caretTimer) {
			caretTimer.destroy();
			caretTimer = null;
		}

		bool blinkingCaret = true;
		static if(UsingSimpledisplayX11)
			if(!Image.impl.xshmAvailable)
				blinkingCaret = false; // if on a remote connection, don't waste bandwidth on an expendable blink

		if(blinkingCaret)
		static if(SimpledisplayTimerAvailable)
		caretTimer = new Timer(500, {
			if(parentWindow.win.closed) {
				caretTimer.destroy();
				return;
			}
			if(isFocused()) {
				auto painter = this.draw();
				textLayout.drawCaret(painter);
			} else if(textLayout.caretShowingOnScreen) {
				auto painter = this.draw();
				textLayout.eraseCaret(painter);
			}
		});
	}

	override void defaultEventHandler_blur(Event ev) {
		super.defaultEventHandler_blur(ev);
		if(parentWindow.win.closed) return;
		version(custom_widgets) {
			auto painter = this.draw();
			textLayout.eraseCaret(painter);
			static if(SimpledisplayTimerAvailable)
			if(caretTimer) {
				caretTimer.destroy();
				caretTimer = null;
			}
		}

		auto evt = new ChangeEvent!string(this, &this.content);
		evt.dispatch();
	}

	version(custom_widgets)
	override void defaultEventHandler_char(CharEvent ev) {
		super.defaultEventHandler_char(ev);
		textLayout.insert(ev.character);
		redraw();

		// FIXME: too inefficient
		auto cbb = textLayout.contentBoundingBox();
		setContentSize(cbb.width, cbb.height);
	}
	version(custom_widgets)
	override void defaultEventHandler_keydown(KeyDownEvent ev) {
		//super.defaultEventHandler_keydown(ev);
		switch(ev.key) {
			case Key.Delete:
				textLayout.delete_();
				redraw();
			break;
			case Key.Left:
				textLayout.moveLeft();
				redraw();
			break;
			case Key.Right:
				textLayout.moveRight();
				redraw();
			break;
			case Key.Up:
				textLayout.moveUp();
				redraw();
			break;
			case Key.Down:
				textLayout.moveDown();
				redraw();
			break;
			case Key.Home:
				textLayout.moveHome();
				redraw();
			break;
			case Key.End:
				textLayout.moveEnd();
				redraw();
			break;
			case Key.PageUp:
				foreach(i; 0 .. 32)
				textLayout.moveUp();
				redraw();
			break;
			case Key.PageDown:
				foreach(i; 0 .. 32)
				textLayout.moveDown();
				redraw();
			break;

			default:
				 {} // intentionally blank, let "char" handle it
		}
		/*
		if(ev.key == Key.Backspace) {
			textLayout.backspace();
			redraw();
		}
		*/
		ensureVisibleInScroll(textLayout.caretBoundingBox());
	}


}

///
class LineEdit : EditableTextWidget {
	// FIXME: hack
	version(custom_widgets) {
	override bool showingVerticalScroll() { return false; }
	override bool showingHorizontalScroll() { return false; }
	}

	///
	this(Widget parent) {
		super(parent);
		version(win32_widgets) {
			createWin32Window(this, "edit"w, "", 
				0, WS_EX_CLIENTEDGE);//|WS_HSCROLL|ES_AUTOHSCROLL);
		} else version(custom_widgets) {
			setupCustomTextEditing();
			addEventListener(delegate(CharEvent ev) {
				if(ev.character == '\n')
					ev.preventDefault();
			});
		} else static assert(false);
	}
	override int maxHeight() { return Window.lineHeight + 4; }
	override int minHeight() { return Window.lineHeight + 4; }

	/+
	@property void passwordMode(bool p) {
		SetWindowLongPtr(hwnd, GWL_STYLE, GetWindowLongPtr(hwnd, GWL_STYLE) | ES_PASSWORD);
	}
	+/
}

/++
	A [LineEdit] that displays `*` in place of the actual characters.

	Alas, Windows requires the window to be created differently to use this style,
	so it had to be a new class instead of a toggle on and off on an existing object.

	FIXME: this is not yet implemented on Linux, it will work the same as a TextEdit there for now.

	History:
		Added January 24, 2021
+/
class PasswordEdit : EditableTextWidget {
	version(custom_widgets) {
	override bool showingVerticalScroll() { return false; }
	override bool showingHorizontalScroll() { return false; }
	}

	///
	this(Widget parent) {
		super(parent);
		version(win32_widgets) {
			createWin32Window(this, "edit"w, "", 
				ES_PASSWORD, WS_EX_CLIENTEDGE);//|WS_HSCROLL|ES_AUTOHSCROLL);
		} else version(custom_widgets) {
			setupCustomTextEditing();
			addEventListener(delegate(CharEvent ev) {
				if(ev.character == '\n')
					ev.preventDefault();
			});
		} else static assert(false);
	}
	override int maxHeight() { return Window.lineHeight + 4; }
	override int minHeight() { return Window.lineHeight + 4; }
}


///
class TextEdit : EditableTextWidget {
	///
	this(Widget parent) {
		super(parent);
		version(win32_widgets) {
			createWin32Window(this, "edit"w, "", 
				0|WS_VSCROLL|WS_HSCROLL|ES_MULTILINE|ES_WANTRETURN|ES_AUTOHSCROLL|ES_AUTOVSCROLL, WS_EX_CLIENTEDGE);
		} else version(custom_widgets) {
			setupCustomTextEditing();
		} else static assert(false);
	}
	override int maxHeight() { return int.max; }
	override int heightStretchiness() { return 7; }
}


/++

+/
version(none)
class RichTextDisplay : Widget {
	@property void content(string c) {}
	void appendContent(string c) {}
}

///
class MessageBox : Window {
	private string message;
	MessageBoxButton buttonPressed = MessageBoxButton.None;
	///
	this(string message, string[] buttons = ["OK"], MessageBoxButton[] buttonIds = [MessageBoxButton.OK]) {
		super(300, 100);

		assert(buttons.length);
		assert(buttons.length ==  buttonIds.length);

		this.message = message;

		int buttonsWidth = cast(int) buttons.length * 50 + (cast(int) buttons.length - 1) * 16;

		int x = this.width / 2 - buttonsWidth / 2;

		foreach(idx, buttonText; buttons) {
			auto button = new Button(buttonText, this);
			button.x = x;
			button.y = height - (button.height + 10);
			button.addEventListener(EventType.triggered, ((size_t idx) { return () {
				this.buttonPressed = buttonIds[idx];
				win.close();
			}; })(idx));

			button.registerMovement();
			x += button.width;
			x += 16;
			if(idx == 0)
				button.focus();
		}

		win.show();
		redraw();
	}

	override void paint(WidgetPainter painter) {
		super.paint(painter);

		auto cs = getComputedStyle();

		painter.outlineColor = cs.foregroundColor();
		painter.fillColor = cs.foregroundColor();

		painter.drawText(Point(0, 0), message, Point(width, height / 2), TextAlignment.Center | TextAlignment.VerticalCenter);
	}

	// this one is all fixed position
	override void recomputeChildLayout() {}
}

///
enum MessageBoxStyle {
	OK, ///
	OKCancel, ///
	RetryCancel, ///
	YesNo, ///
	YesNoCancel, ///
	RetryCancelContinue /// In a multi-part process, if one part fails, ask the user if you should retry that failed step, cancel the entire process, or just continue with the next step, accepting failure on this step.
}

///
enum MessageBoxIcon {
	None, ///
	Info, ///
	Warning, ///
	Error ///
}

/// Identifies the button the user pressed on a message box.
enum MessageBoxButton {
	None, /// The user closed the message box without clicking any of the buttons.
	OK, ///
	Cancel, ///
	Retry, ///
	Yes, ///
	No, ///
	Continue ///
}


/++
	Displays a modal message box, blocking until the user dismisses it.

	Returns: the button pressed.
+/
MessageBoxButton messageBox(string title, string message, MessageBoxStyle style = MessageBoxStyle.OK, MessageBoxIcon icon = MessageBoxIcon.None) {
	version(win32_widgets) {
		WCharzBuffer t = WCharzBuffer(title);
		WCharzBuffer m = WCharzBuffer(message);
		UINT type;
		with(MessageBoxStyle)
		final switch(style) {
			case OK: type |= MB_OK; break;
			case OKCancel: type |= MB_OKCANCEL; break;
			case RetryCancel: type |= MB_RETRYCANCEL; break;
			case YesNo: type |= MB_YESNO; break;
			case YesNoCancel: type |= MB_YESNOCANCEL; break;
			case RetryCancelContinue: type |= MB_CANCELTRYCONTINUE; break;
		}
		with(MessageBoxIcon)
		final switch(icon) {
			case None: break;
			case Info: type |= MB_ICONINFORMATION; break;
			case Warning: type |= MB_ICONWARNING; break;
			case Error: type |= MB_ICONERROR; break;
		}
		switch(MessageBoxW(null, m.ptr, t.ptr, type)) {
			case IDOK: return MessageBoxButton.OK;
			case IDCANCEL: return MessageBoxButton.Cancel;
			case IDTRYAGAIN, IDRETRY: return MessageBoxButton.Retry;
			case IDYES: return MessageBoxButton.Yes;
			case IDNO: return MessageBoxButton.No;
			case IDCONTINUE: return MessageBoxButton.Continue;
			default: return MessageBoxButton.None;
		}
	} else {
		string[] buttons;
		MessageBoxButton[] buttonIds;
		with(MessageBoxStyle)
		final switch(style) {
			case OK:
				buttons = ["OK"];
				buttonIds = [MessageBoxButton.OK];
			break;
			case OKCancel:
				buttons = ["OK", "Cancel"];
				buttonIds = [MessageBoxButton.OK, MessageBoxButton.Cancel];
			break;
			case RetryCancel:
				buttons = ["Retry", "Cancel"];
				buttonIds = [MessageBoxButton.Retry, MessageBoxButton.Cancel];
			break;
			case YesNo:
				buttons = ["Yes", "No"];
				buttonIds = [MessageBoxButton.Yes, MessageBoxButton.No];
			break;
			case YesNoCancel:
				buttons = ["Yes", "No", "Cancel"];
				buttonIds = [MessageBoxButton.Yes, MessageBoxButton.No, MessageBoxButton.Cancel];
			break;
			case RetryCancelContinue:
				buttons = ["Try Again", "Cancel", "Continue"];
				buttonIds = [MessageBoxButton.Retry, MessageBoxButton.Cancel, MessageBoxButton.Continue];
			break;
		}
		auto mb = new MessageBox(message, buttons, buttonIds);
		EventLoop el = EventLoop.get;
		el.run(() { return !mb.win.closed; });
		return mb.buttonPressed;
	}
}

/// ditto
int messageBox(string message, MessageBoxStyle style = MessageBoxStyle.OK, MessageBoxIcon icon = MessageBoxIcon.None) {
	return messageBox(null, message, style, icon);
}



///
alias void delegate(Widget handlerAttachedTo, Event event) EventHandler;

/++
	This is an opaque type you can use to disconnect an event handler when you're no longer interested.

	History:
		The data members were `public` (albiet undocumented and not intended for use) prior to May 13, 2021. They are now `private`, reflecting the single intended use of this object.
+/
struct EventListener {
	private Widget widget;
	private string event;
	private EventHandler handler;
	private bool useCapture;

	///
	void disconnect() {
		widget.removeEventListener(this);
	}
}

/++
	The purpose of this enum was to give a compile-time checked version of various standard event strings.

	Now, I recommend you use a statically typed event object instead.

	See_Also: [Event]
+/
enum EventType : string {
	click = "click", ///

	mouseenter = "mouseenter", ///
	mouseleave = "mouseleave", ///
	mousein = "mousein", ///
	mouseout = "mouseout", ///
	mouseup = "mouseup", ///
	mousedown = "mousedown", ///
	mousemove = "mousemove", ///

	keydown = "keydown", ///
	keyup = "keyup", ///
	char_ = "char", ///

	focus = "focus", ///
	blur = "blur", ///

	triggered = "triggered", ///

	change = "change", ///
}

/++
	Represents an event that is currently being processed.


	Minigui's event model is based on the web browser. An event has a name, a target,
	and an associated data object. It starts from the window and works its way down through
	the target through all intermediate [Widget]s, triggering capture phase handlers as it goes,
	then goes back up again all the way back to the window, triggering bubble phase handlers. At
	the end, if [Event.preventDefault] has not been called, it calls the target widget's default
	handlers for the event (please note that default handlers will be called even if [Event.stopPropagation]
	was called; that just stops it from calling other handlers in the widget tree, but the default happens
	whenever propagation is done, not only if it gets to the end of the chain).

	This model has several nice points:

	$(LIST
		* It is easy to delegate dynamic handlers to a parent. You can have a parent container
		  with event handlers set, then add/remove children as much as you want without needing
		  to manage the event handlers on them - the parent alone can manage everything.

		* It is easy to create new custom events in your application.

		* It is familiar to many web developers.
	)

	There's a few downsides though:

	$(LIST
		* There's not a lot of type safety.

		* You don't get a static list of what events a widget can emit.

		* Tracing where an event got cancelled along the chain can get difficult; the downside of
		  the central delegation benefit is it can be lead to debugging of action at a distance.
	)

	In May 2021, I started to adjust this model to minigui takes better advantage of D over Javascript
	while keeping the benefits - and most compatibility with - the existing model. The main idea is
	to simply use a D object type which provides a static interface as well as a built-in event name.
	Then, a new static interface allows you to see what an event can emit and attach handlers to it
	similarly to C#, which just forwards to the JS style api. They're fully compatible so you can still
	delegate to a parent and use custom events as well as using the runtime dynamic access, in addition
	to having a little more help from the D compiler and documentation generator.

	Your code would change like this:

	---
	// old
	widget.addEventListener("keydown", (Event ev) { ... }, /* optional arg */ useCapture );

	// new
	widget.addEventListener((KeyDownEvent ev) { ... }, /* optional arg */ useCapture );
	---

	The old-style code will still work, but using certain members of the [Event] class will generate deprecation warnings. Changing handlers to the new style will silence all those warnings at once without requiring any other changes to your code.

	All you have to do is replace the string with a specific Event subclass. It will figure out the event string from the class.

	Alternatively, you can cast the Event yourself to the appropriate subclass, but it is easier to let the library do it for you!

	Thus the family of functions are:

	[Widget.addEventListener] is the fully-flexible base method. It has two main overload families: one with the string and one without. The one with the string takes the Event object, the one without determines the string from the type you pass. The string "*" matches ALL events that pass through.

	[Widget.addDirectEventListener] is addEventListener, but only calls the handler if target == this. Useful for something you can't afford to delegate.

	[Widget.setDefaultEventHandler] is what is called if no preventDefault was called. This should be called in the widget's constructor to set default behaivor. Default event handlers are only called on the event target.

	Let's implement a custom widget that can emit a ChangeEvent describing its `checked` property:

	---
	class MyCheckbox : Widget {
		/// This gives a chance to document it and generates a convenience function to send it and attach handlers.
		/// It is NOT actually required but should be used whenever possible.
		mixin Emits!(ChangeEvent!bool);

		this(Widget parent) {
			super(parent);
			setDefaultEventHandler((ClickEvent) { checked = !checked; });
		}

		private bool _checked;
		@property bool checked() { return _checked; }
		@property void checked(bool set) {
			_checked = set;
			emit!(ChangeEvent!bool)(&checked);
		}
	}
	---

	## Creating Your Own Events

	To avoid clashing in the string namespace, your events should use your module and class name as the event string. The simple code `mixin Register;` in your Event subclass will do this for you.

	---
	class MyEvent : Event {
		this(Widget target) { super(EventString, target); }
		mixin Register; // adds EventString and other reflection information
	}
	---

	Then declare that it is sent with the [Emits] mixin, so you can use [Widget.emit] to dispatch it.

	History:
		Prior to May 2021, Event had a set of pre-made members with no extensibility (outside of diy casts) and no static checks on field presence.

		After that, those old pre-made members are deprecated accessors and the fields are moved to child classes. To transition, change string events to typed events or do a dynamic cast (don't forget the null check!) in your handler.
+/
/+

	## General Conventions

	Change events should NOT be emitted when a value is changed programmatically. Indeed, methods should usually not send events. The point of an event is to know something changed and when you call a method, you already know about it.


	## Qt-style signals and slots

	Some events make sense to use with just name and data type. These are one-way notifications with no propagation nor default behavior and thus separate from the other event system.

	The intention is for events to be used when

	---
	class Demo : Widget {
		this() {
			myPropertyChanged = Signal!int(this);
		}
		@property myProperty(int v) {
			myPropertyChanged.emit(v);
		}

		Signal!int myPropertyChanged; // i need to get `this` off it and inspect the name...
		// but it can just genuinely not care about `this` since that's not really passed.
	}

	class Foo : Widget {
		// the slot uda is not necessary, but it helps the script and ui builder find it.
		@slot void setValue(int v) { ... }
	}

	demo.myPropertyChanged.connect(&foo.setValue);
	---

	The Signal type has a disabled default constructor, meaning your widget constructor must pass `this` to it in its constructor.

	Some events may also wish to implement the Signal interface. These use particular arguments to call a method automatically.

	class StringChangeEvent : ChangeEvent, Signal!string {
		mixin SignalImpl
	}

+/
class Event : ReflectableProperties {
	/// Creates an event without populating any members and without sending it. See [dispatch]
	this(string eventName, Widget emittedBy) {
		this.eventName = eventName;
		this.srcElement = emittedBy;
	}


	/// Implementations for the [ReflectableProperties] interface/
	void getPropertiesList(scope void delegate(string name) sink) const {}
	/// ditto
	void getPropertyAsString(string name, scope void delegate(string name, scope const(char)[] value, bool valueIsJson) sink) { }
	/// ditto
	SetPropertyResult setPropertyFromString(string name, scope const(char)[] str, bool strIsJson) {
		return SetPropertyResult.notPermitted;
	}


	/+
	/++
		This is an internal implementation detail of [Register] and is subject to be changed or removed at any time without notice.

		It is just protected so the mixin template can see it from user modules. If I made it private, even my own mixin template couldn't see it due to mixin scoping rules.
	+/
	protected final void sinkJsonString(string memberName, scope const(char)[] value, scope void delegate(string name, scope const(char)[] value) finalSink) {
		if(value.length == 0) {
			finalSink(memberName, `""`);
			return;
		}

		char[1024] bufferBacking;
		char[] buffer = bufferBacking;
		int bufferPosition;

		void sink(char ch) {
			if(bufferPosition >= buffer.length)
				buffer.length = buffer.length + 1024;
			buffer[bufferPosition++] = ch;
		}

		sink('"');

		foreach(ch; value) {
			switch(ch) {
				case '\\':
					sink('\\'); sink('\\');
				break;
				case '"':
					sink('\\'); sink('"');
				break;
				case '\n':
					sink('\\'); sink('n');
				break;
				case '\r':
					sink('\\'); sink('r');
				break;
				case '\t':
					sink('\\'); sink('t');
				break;
				default:
					sink(ch);
			}
		}

		sink('"');

		finalSink(memberName, buffer[0 .. bufferPosition]);
	}
	+/

	/+
	enum EventInitiator {
		system,
		minigui,
		user
	}

	immutable EventInitiator; initiatedBy;
	+/

	/++
		Events should generally follow the propagation model, but there's some exceptions
		to that rule. If so, they should override this to return false. In that case, only
		bubbling event handlers on the target itself and capturing event handlers on the containing
		window will be called. (That is, [dispatch] will call [sendDirectly] instead of doing the normal
		capture -> target -> bubble process.)

		History:
			Added May 12, 2021
	+/
	bool propagates() const pure nothrow @nogc @safe {
		return true;
	}

	/++
		hints as to whether preventDefault will actually do anything. not entirely reliable.

		History:
			Added May 14, 2021
	+/
	bool cancelable() const pure nothrow @nogc @safe {
		return true;
	}

	/++
		You can mix this into child class to register some boilerplate. It includes the `EventString`
		member, a constructor, and implementations of the dynamic get data interfaces.

		If you fail to do this, your event will probably not have full compatibility but it might still work for you.


		You can override the default EventString by simply providing your own in the form of
		`enum string EventString = "some.name";` The default is the name of your class and its parent entity
		which provides some namespace protection against conflicts in other libraries while still being fairly
		easy to use.

		If you provide your own constructor, it will override the default constructor provided here. A constructor
		must call `super(EventString, passed_widget_target)` at some point. The `passed_widget_target` must be the
		first argument to your constructor.

		History:
			Added May 13, 2021.
	+/
	protected static mixin template Register() {
		public enum string EventString = __traits(identifier, __traits(parent, typeof(this))) ~ "." ~  __traits(identifier, typeof(this));
		this(Widget target) { super(EventString, target); }

		mixin ReflectableProperties.RegisterGetters;
	}

	/++
		This is the widget that emitted the event.


		The aliased names come from Javascript for ease of web developers to transition in, but they're all synonyms.

		History:
			The `source` name was added on May 14, 2021. It is a little weird that `source` and `target` are synonyms,
			but that's a side effect of it doing both capture and bubble handlers and people are used to it from the web
			so I don't intend to remove these aliases.
	+/
	Widget source;
	/// ditto
	alias source target;
	/// ditto
	alias source srcElement;

	Widget relatedTarget; /// Note: likely to be deprecated at some point.

	/// Prevents the default event handler (if there is one) from being called
	void preventDefault() {
		lastDefaultPrevented = true;
		defaultPrevented = true;
	}

	/// Stops the event propagation immediately.
	void stopPropagation() {
		propagationStopped = true;
	}

	private bool defaultPrevented;
	private bool propagationStopped;
	private string eventName;

	private bool isBubbling;

	/// This is an internal implementation detail you should not use. It would be private if the language allowed it and it may be removed without notice.
	protected void adjustScrolling() { }
	/// ditto
	protected void adjustClientCoordinates(int deltaX, int deltaY) { }

	/++
		this sends it only to the target. If you want propagation, use dispatch() instead.

		This should be made private!!!

	+/
	void sendDirectly() {
		if(srcElement is null)
			return;

		// i capturing on the parent too. The main reason for this is that gives a central place to log all events for the debug window.

		//debug if(eventName != "mousemove" && target !is null && target.parentWindow && target.parentWindow.devTools)
			//target.parentWindow.devTools.log("Event ", eventName, " dispatched directly to ", srcElement);

		adjustScrolling();

		if(auto e = target.parentWindow) {
			if(auto handlers = "*" in e.capturingEventHandlers)
			foreach(handler; *handlers)
				if(handler) handler(e, this);
			if(auto handlers = eventName in e.capturingEventHandlers)
			foreach(handler; *handlers)
				if(handler) handler(e, this);
		}

		auto e = srcElement;

		if(auto handlers = eventName in e.bubblingEventHandlers)
		foreach(handler; *handlers)
			if(handler) handler(e, this);

		if(auto handlers = "*" in e.bubblingEventHandlers)
		foreach(handler; *handlers)
			if(handler) handler(e, this);

		// there's never a default for a catch-all event
		if(!defaultPrevented)
			if(eventName in e.defaultEventHandlers)
				e.defaultEventHandlers[eventName](e, this);
	}

	/// this dispatches the element using the capture -> target -> bubble process
	void dispatch() {
		if(srcElement is null)
			return;

		if(!propagates) {
			sendDirectly;
			return;
		}

		//debug if(eventName != "mousemove" && target !is null && target.parentWindow && target.parentWindow.devTools)
			//target.parentWindow.devTools.log("Event ", eventName, " dispatched to ", srcElement);

		adjustScrolling();
		// first capture, then bubble

		Widget[] chain;
		Widget curr = srcElement;
		while(curr) {
			auto l = curr;
			chain ~= l;
			curr = curr.parent;
		}

		isBubbling = false;

		foreach_reverse(e; chain) {
			if(auto handlers = "*" in e.capturingEventHandlers)
				foreach(handler; *handlers) if(handler !is null) handler(e, this);

			if(propagationStopped)
				break;

			if(auto handlers = eventName in e.capturingEventHandlers)
				foreach(handler; *handlers) if(handler !is null) handler(e, this);

			// the default on capture should really be to always do nothing

			//if(!defaultPrevented)
			//	if(eventName in e.defaultEventHandlers)
			//		e.defaultEventHandlers[eventName](e.element, this);

			if(propagationStopped)
				break;
		}

		int adjustX;
		int adjustY;

		isBubbling = true;
		if(!propagationStopped)
		foreach(e; chain) {
			if(auto handlers = eventName in e.bubblingEventHandlers)
				foreach(handler; *handlers) if(handler !is null) handler(e, this);

			if(propagationStopped)
				break;

			if(auto handlers = "*" in e.bubblingEventHandlers)
				foreach(handler; *handlers) if(handler !is null) handler(e, this);

			if(propagationStopped)
				break;

			if(e.encapsulatedChildren()) {
				adjustClientCoordinates(adjustX, adjustY);
				target = e;
			} else {
				adjustX += e.x;
				adjustY += e.y;
			}
		}

		if(!defaultPrevented)
		foreach(e; chain) {
			if(eventName in e.defaultEventHandlers)
				e.defaultEventHandlers[eventName](e, this);
		}
	}


	/* old compatibility things */
	deprecated("Use some subclass of KeyEventBase instead of plain Event in your handler going forward")
	final @property {
		Key key() { return (cast(KeyEventBase) this).key; }
		KeyEvent originalKeyEvent() { return (cast(KeyEventBase) this).originalKeyEvent; }

		bool ctrlKey() { return (cast(KeyEventBase) this).ctrlKey; }
		bool altKey() { return (cast(KeyEventBase) this).altKey; }
		bool shiftKey() { return (cast(KeyEventBase) this).shiftKey; }
	}

	deprecated("Use some subclass of MouseEventBase instead of Event in your handler going forward")
	final @property {
		int clientX() { return (cast(MouseEventBase) this).clientX; }
		int clientY() { return (cast(MouseEventBase) this).clientY; }

		int viewportX() { return (cast(MouseEventBase) this).viewportX; }
		int viewportY() { return (cast(MouseEventBase) this).viewportY; }

		int button() { return (cast(MouseEventBase) this).button; }
		int buttonLinear() { return (cast(MouseEventBase) this).buttonLinear; }
	}

	deprecated("Use either a KeyEventBase or a MouseEventBase instead of Event in your handler going forward")
	final @property {
		int state() {
			if(auto meb = cast(MouseEventBase) this)
				return meb.state;
			if(auto keb = cast(KeyEventBase) this)
				return keb.state;
			assert(0);
		}
	}

	deprecated("Use a CharEvent instead of Event in your handler going forward")
	final @property {
		dchar character() {
			if(auto ce = cast(CharEvent) this)
				return ce.character;
			return dchar.init;
		}
	}

	// for change events
	@property {
		///
		int intValue() { return 0; }
		///
		string stringValue() { return null; }
	}
}

/++
	This lets you statically verify you send the events you claim you send and gives you a hook to document them.

	Please note that a widget may send events not listed as Emits. You can always construct and dispatch
	dynamic and custom events, but the static list helps ensure you get them right.

	If this is declared, you can use [Widget.emit] to send the event.

	All events work the same way though, following the capture->widget->bubble model described under [Event].

	History:
		Added May 4, 2021
+/
mixin template Emits(EventType) {
	import arsd.minigui : EventString;
	static if(is(EventType : Event) && !is(EventType == Event))
		mixin("private EventType[0] emits_" ~ EventStringIdentifier!EventType ~";");
	else
		static assert(0, "You can only emit subclasses of Event");
}

/// ditto
mixin template Emits(string eventString) {
	mixin("private Event[0] emits_" ~ eventString ~";");
}

/*
class SignalEvent(string name) : Event {

}
*/

/++
	Command Events are used with a widget wants to issue a higher-level, yet loosely coupled command do its parents and other interested listeners, for example, "scroll up".


	Command Events are a bit special in the way they're used. You don't typically refer to them by object, but instead by a name string and a set of arguments. The expectation is that they will be delegated to a parent, which "consumes" the command - it handles it and stops its propagation upward. The [consumesCommand] method will call your handler with the arguments, then stop the command event's propagation for you, meaning you don't have to call [Event.stopPropagation]. A command event should have no default behavior, so calling [Event.preventDefault] is not necessary either.

	History:
		Added on May 13, 2021. Prior to that, you'd most likely `addEventListener(EventType.triggered, ...)` to handle similar things.
+/
class CommandEvent : Event {
	enum EventString = "command";
	this(Widget source, string CommandString = EventString) {
		super(CommandString, source);
	}
}

/++
	A [CommandEvent] is typically actually an instance of these to hold the strongly-typed arguments.
+/
class CommandEventWithArgs(Args...) : CommandEvent {
	this(Widget source, string CommandString, Args args) { super(source, CommandString); this.args = args; }
	Args args;
}

/++
	Declares that the given widget consumes a command identified by the `CommandString` AND containing `Args`. Your `handler` is called with the arguments, then the event's propagation is stopped, so it will not be seen by the consumer's parents.

	See [CommandEvent] for more information.

	Returns:
		The [EventListener] you can use to remove the handler.
+/
EventListener consumesCommand(string CommandString, WidgetType, Args...)(WidgetType w, void delegate(Args) handler) {
	return w.addEventListener(CommandString, (Event ev) {
		if(ev.target is w)
			return; // it does not consume its own commands!
		if(auto cev = cast(CommandEventWithArgs!Args) ev) {
			handler(cev.args);
			ev.stopPropagation();
		}
	});
}

/++
	Emits a command to the sender widget's parents with the given `CommandString` and `args`. You have no way of knowing if it was ever actually consumed due to the loose coupling. Instead, the consumer may broadcast a state update back toward you.
+/
void emitCommand(string CommandString, WidgetType, Args...)(WidgetType w, Args args) {
	auto event = new CommandEventWithArgs!Args(w, CommandString, args);
	event.dispatch();
}

class ResizeEvent : Event {
	enum EventString = "resize";

	this(Widget target) { super(EventString, target); }

	override bool propagates() const { return false; }
}

class BlurEvent : Event {
	enum EventString = "blur";

	// FIXME: related target?
	this(Widget target) { super(EventString, target); }

	override bool propagates() const { return false; }
}

class FocusEvent : Event {
	enum EventString = "focus";

	// FIXME: related target?
	this(Widget target) { super(EventString, target); }
}

class ScrollEvent : Event {
	enum EventString = "scroll";
	this(Widget target) { super(EventString, target); }

	override bool cancelable() const { return false; }
}

/++
	Indicates that a character has been typed by the user. Normally dispatched to the currently focused widget.

	History:
		Added May 2, 2021. Previously, this was simply a "char" event and `character` as a member of the [Event] base class.
+/
class CharEvent : Event {
	enum EventString = "char";
	this(Widget target, dchar ch) {
		character = ch;
		super(EventString, target);
	}

	immutable dchar character;
}

/++
	You should generally use a `ChangeEvent!Type` instead of this directly. See [ChangeEvent] for more information.
+/
abstract class ChangeEventBase : Event {
	enum EventString = "change";
	this(Widget target) {
		super(EventString, target);
	}

	/+
		// idk where or how exactly i want to do this.
		// i might come back to it later.

	// If a widget itself broadcasts one of theses itself, it stops propagation going down
	// this way the source doesn't get too confused (think of a nested scroll widget)
	//
	// the idea is like the scroll bar emits a command event saying like "scroll left one line"
	// then you consume that command and change you scroll x position to whatever. then you do
	// some kind of change event that is broadcast back to the children and any horizontal scroll
	// listeners are now able to update, without having an explicit connection between them.
	void broadcastToChildren(string fieldName) {

	}
	+/
}

/++
	Single-value widgets (that is, ones with a programming interface that just expose a value that the user has control over) should emit this after their value changes.


	Generally speaking, if your widget can reasonably have a `@property T value();` or `@property bool checked();` method, it should probably emit this event when that value changes to inform its parents that they can now read a new value. Whether you emit it on each keystroke or other intermediate values or only when a value is committed (e.g. when the user leaves the field) is up to the widget. You might even make that a togglable property depending on your needs (emitting events can get expensive).

	The delegate you pass to the constructor ought to be a handle to your getter property. If your widget has `@property string value()` for example, you emit `ChangeEvent!string(&value);`

	Since it is emitted after the value has already changed, [preventDefault] is unlikely to do anything.

	History:
		Added May 11, 2021. Prior to that, widgets would more likely just send `new Event("change")`. These typed ChangeEvents are still compatible with listeners subscribed to generic change events.
+/
class ChangeEvent(T) : ChangeEventBase {
	this(Widget target, T delegate() getNewValue) {
		assert(getNewValue !is null);
		this.getNewValue = getNewValue;
		super(target);
	}

	private T delegate() getNewValue;

	/++
		Gets the new value that just changed.
	+/
	@property T value() {
		return getNewValue();
	}

	/// compatibility method for old generic Events
	static if(is(immutable T == immutable int))
		override int intValue() { return value; }
	/// ditto
	static if(is(immutable T == immutable string))
		override string stringValue() { return value; }
}

/++
	Contains shared properties for [KeyDownEvent]s and [KeyUpEvent]s.


	You can construct these yourself, but generally the system will send them to you and there's little need to emit your own.

	History:
		Added May 2, 2021. Previously, its properties were members of the [Event] base class.
+/
abstract class KeyEventBase : Event {
	this(string name, Widget target) {
		super(name, target);
	}

	// for key events
	Key key; ///

	KeyEvent originalKeyEvent;

	/++
		Indicates the current state of the given keyboard modifier keys.

		History:
			Added to events on April 15, 2020.
	+/
	bool ctrlKey;

	/// ditto
	bool altKey;

	/// ditto
	bool shiftKey;

	/++
		The raw bitflags that are parsed out into [ctrlKey], [altKey], and [shiftKey].

		See [arsd.simpledisplay.ModifierState] for other possible flags.
	+/
	int state;

	mixin Register;
}

/++
	Indicates that the user has pressed a key on the keyboard, or if they've been holding it long enough to repeat (key down events are sent both on the initial press then repeated by the OS on its own time.) For available properties, see [KeyEventBase].


	You can construct these yourself, but generally the system will send them to you and there's little need to emit your own.

	Please note that a `KeyDownEvent` will also often send a [CharEvent], but there is not necessarily a one-to-one relationship between them. For example, a capital letter may send KeyDownEvent for Key.Shift, then KeyDownEvent for the letter's key (this key may not match the letter due to keyboard mappings), then CharEvent for the letter, then KeyUpEvent for the letter, and finally, KeyUpEvent for shift.

	For some characters, there are other key down events as well. A compose key can be pressed and released, followed by several letters pressed and released to generate one character. This is why [CharEvent] is a separate entity.

	See_Also: [KeyUpEvent], [CharEvent]

	History:
		Added May 2, 2021. Previously, it was only seen as the base [Event] class on "keydown" event listeners.
+/
class KeyDownEvent : KeyEventBase {
	enum EventString = "keydown";
	this(Widget target) { super(EventString, target); }
}

/++
	Indicates that the user has released a key on the keyboard. For available properties, see [KeyEventBase].


	You can construct these yourself, but generally the system will send them to you and there's little need to emit your own.

	See_Also: [KeyDownEvent], [CharEvent]

	History:
		Added May 2, 2021. Previously, it was only seen as the base [Event] class on "keyup" event listeners.
+/
class KeyUpEvent : KeyEventBase {
	enum EventString = "keyup";
	this(Widget target) { super(EventString, target); }
}

/++
	Contains shared properties for various mouse events;


	You can construct these yourself, but generally the system will send them to you and there's little need to emit your own.

	History:
		Added May 2, 2021. Previously, its properties were members of the [Event] base class.
+/
abstract class MouseEventBase : Event {
	this(string name, Widget target) {
		super(name, target);
	}

	// for mouse events
	int clientX; /// The mouse event location relative to the target widget
	int clientY; /// ditto

	int viewportX; /// The mouse event location relative to the window origin
	int viewportY; /// ditto

	int button; /// See: [MouseEvent.button]
	int buttonLinear; /// See: [MouseEvent.buttonLinear]

	int state; ///

	/++
		Mouse wheel movement sends down/up/click events just like other buttons clicking. This method is to help you filter that out.

		History:
			Added May 15, 2021
	+/
	bool isMouseWheel() {
		return button == MouseButton.wheelUp || button == MouseButton.wheelDown;
	}

	// private
	override void adjustClientCoordinates(int deltaX, int deltaY) {
		clientX += deltaX;
		clientY += deltaY;
	}

	override void adjustScrolling() {
	version(custom_widgets) { // TEMP
		viewportX = clientX;
		viewportY = clientY;
		if(auto se = cast(ScrollableWidget) srcElement) {
			clientX += se.scrollOrigin.x;
			clientY += se.scrollOrigin.y;
		}
	}
	}

	mixin Register;
}

/++
	Indicates that the user has worked with the mouse over your widget. For available properties, see [MouseEventBase].


	$(WARNING
		Important: MouseDownEvent, MouseUpEvent, ClickEvent, and DoubleClickEvent are all sent for all mouse buttons and
		for wheel movement! You should check the [MouseEventBase.button|button] property in most your handlers to get correct
		behavior.
	)

	[MouseDownEvent] is sent when the user presses a mouse button. It is also sent on mouse wheel movement.

	[MouseUpEvent] is sent when the user releases a mouse button.

	[MouseMoveEvent] is sent when the mouse is moved. Please note you may not receive this in some cases unless a button is also pressed; the system is free to withhold them as an optimization. (In practice, [arsd.simpledisplay] does not request mouse motion event without a held button if it is on a remote X11 link, but does elsewhere at this time.)

	[ClickEvent] is sent when the user clicks on the widget. It may also be sent with keyboard control, though minigui prefers to send a "triggered" event in addition to a mouse click and instead of a simulated mouse click in cases like keyboard activation of a button.

	[DoubleClickEvent] is sent when the user clicks twice on a thing quickly, immediately after the second MouseDownEvent. The sequence is: MouseDownEvent, MouseUpEvent, ClickEvent, MouseDownEvent, DoubleClickEvent, MouseUpEvent. The second ClickEvent is NOT sent. Note that this is differnet than Javascript! They would send down,up,click,down,up,click,dblclick. Minigui does it differently because this is the way the Windows OS reports it.

	[MouseOverEvent] is sent then the mouse first goes over a widget. Please note that this participates in event propagation of children! Use [MouseEnterEvent] instead if you are only interested in a specific element's whole bounding box instead of the top-most element in any particular location.

	[MouseOutEvent] is sent when the mouse exits a target. Please note that this participates in event propagation of children! Use [MouseLeaveEvent] instead if you are only interested in a specific element's whole bounding box instead of the top-most element in any particular location.

	[MouseEnterEvent] is sent when the mouse enters the bounding box of a widget.

	[MouseLeaveEvent] is sent when the mouse leaves the bounding box of a widget.

	You can construct these yourself, but generally the system will send them to you and there's little need to emit your own.

	Rationale:

		If you only want to do drag, mousedown/up works just fine being consistently sent.

		If you want click, that event does what you expect (if the user mouse downs then moves the mouse off the widget before going up, no click event happens - a click is only down and back up on the same thing).

		If you want double click and listen to that specifically, it also just works, and if you only cared about clicks, odds are the double click should do the same thing as a single click anyway - the double was prolly accidental - so only sending the event once is prolly what user intended.

	History:
		Added May 2, 2021. Previously, it was only seen as the base [Event] class on event listeners. See the member [EventString] to see what the associated string is with these elements.
+/
class MouseUpEvent : MouseEventBase {
	enum EventString = "mouseup"; ///
	this(Widget target) { super(EventString, target); }
}
/// ditto
class MouseDownEvent : MouseEventBase {
	enum EventString = "mousedown"; ///
	this(Widget target) { super(EventString, target); }
}
/// ditto
class MouseMoveEvent : MouseEventBase {
	enum EventString = "mousemove"; ///
	this(Widget target) { super(EventString, target); }
}
/// ditto
class ClickEvent : MouseEventBase {
	enum EventString = "click"; ///
	this(Widget target) { super(EventString, target); }
}
/// ditto
class DoubleClickEvent : MouseEventBase {
	enum EventString = "dblclick"; ///
	this(Widget target) { super(EventString, target); }
}
/// ditto
class MouseOverEvent : Event {
	enum EventString = "mouseover"; ///
	this(Widget target) { super(EventString, target); }
}
/// ditto
class MouseOutEvent : Event {
	enum EventString = "mouseout"; ///
	this(Widget target) { super(EventString, target); }
}
/// ditto
class MouseEnterEvent : Event {
	enum EventString = "mouseenter"; ///
	this(Widget target) { super(EventString, target); }

	override bool propagates() const { return false; }
}
/// ditto
class MouseLeaveEvent : Event {
	enum EventString = "mouseleave"; ///
	this(Widget target) { super(EventString, target); }

	override bool propagates() const { return false; }
}

private bool isAParentOf(Widget a, Widget b) {
	if(a is null || b is null)
		return false;

	while(b !is null) {
		if(a is b)
			return true;
		b = b.parent;
	}

	return false;
}

private struct WidgetAtPointResponse {
	Widget widget;
	int x;
	int y;
}

private WidgetAtPointResponse widgetAtPoint(Widget starting, int x, int y) {
	assert(starting !is null);
	auto child = starting.getChildAtPosition(x, y);
	while(child) {
		if(child.hidden)
			continue;
		starting = child;
		x -= child.x;
		y -= child.y;
		auto r = starting.widgetAtPoint(x, y);//starting.getChildAtPosition(x, y);
		child = r.widget;
		if(child is starting)
			break;
	}
	return WidgetAtPointResponse(starting, x, y);
}

version(win32_widgets) {
private:
	import core.sys.windows.commctrl;

	pragma(lib, "comctl32");
	shared static this() {
		// http://msdn.microsoft.com/en-us/library/windows/desktop/bb775507(v=vs.85).aspx
		INITCOMMONCONTROLSEX ic;
		ic.dwSize = cast(DWORD) ic.sizeof;
		ic.dwICC = ICC_UPDOWN_CLASS | ICC_WIN95_CLASSES | ICC_BAR_CLASSES | ICC_PROGRESS_CLASS | ICC_COOL_CLASSES | ICC_STANDARD_CLASSES | ICC_USEREX_CLASSES;
		if(!InitCommonControlsEx(&ic)) {
			//import std.stdio; writeln("ICC failed");
		}
	}


	// everything from here is just win32 headers copy pasta
private:
extern(Windows):

	alias HANDLE HMENU;
	HMENU CreateMenu();
	bool SetMenu(HWND, HMENU);
	HMENU CreatePopupMenu();
	enum MF_POPUP = 0x10;
	enum MF_STRING = 0;


	BOOL InitCommonControlsEx(const INITCOMMONCONTROLSEX*);
	struct INITCOMMONCONTROLSEX {
		DWORD dwSize;
		DWORD dwICC;
	}
	enum HINST_COMMCTRL = cast(HINSTANCE) (-1);
enum {
        IDB_STD_SMALL_COLOR,
        IDB_STD_LARGE_COLOR,
        IDB_VIEW_SMALL_COLOR = 4,
        IDB_VIEW_LARGE_COLOR = 5
}
enum {
        STD_CUT,
        STD_COPY,
        STD_PASTE,
        STD_UNDO,
        STD_REDOW,
        STD_DELETE,
        STD_FILENEW,
        STD_FILEOPEN,
        STD_FILESAVE,
        STD_PRINTPRE,
        STD_PROPERTIES,
        STD_HELP,
        STD_FIND,
        STD_REPLACE,
        STD_PRINT // = 14
}

alias HANDLE HIMAGELIST;
	HIMAGELIST ImageList_Create(int, int, UINT, int, int);
	int ImageList_Add(HIMAGELIST, HBITMAP, HBITMAP);
        BOOL ImageList_Destroy(HIMAGELIST);

uint MAKELONG(ushort a, ushort b) {
        return cast(uint) ((b << 16) | a);
}


struct TBBUTTON {
	int   iBitmap;
	int   idCommand;
	BYTE  fsState;
	BYTE  fsStyle;
	version(Win64)
	BYTE[6] bReserved;
	else
	BYTE[2]  bReserved;
	DWORD dwData;
	INT_PTR   iString;
}

	enum {
		TB_ADDBUTTONSA   = WM_USER + 20,
		TB_INSERTBUTTONA = WM_USER + 21,
		TB_GETIDEALSIZE = WM_USER + 99,
	}

struct SIZE {
	LONG cx;
	LONG cy;
}


enum {
	TBSTATE_CHECKED       = 1,
	TBSTATE_PRESSED       = 2,
	TBSTATE_ENABLED       = 4,
	TBSTATE_HIDDEN        = 8,
	TBSTATE_INDETERMINATE = 16,
	TBSTATE_WRAP          = 32
}



enum {
	ILC_COLOR    = 0,
	ILC_COLOR4   = 4,
	ILC_COLOR8   = 8,
	ILC_COLOR16  = 16,
	ILC_COLOR24  = 24,
	ILC_COLOR32  = 32,
	ILC_COLORDDB = 254,
	ILC_MASK     = 1,
	ILC_PALETTE  = 2048
}


alias TBBUTTON*       PTBBUTTON, LPTBBUTTON;


enum {
	TB_ENABLEBUTTON          = WM_USER + 1,
	TB_CHECKBUTTON,
	TB_PRESSBUTTON,
	TB_HIDEBUTTON,
	TB_INDETERMINATE, //     = WM_USER + 5,
	TB_ISBUTTONENABLED       = WM_USER + 9,
	TB_ISBUTTONCHECKED,
	TB_ISBUTTONPRESSED,
	TB_ISBUTTONHIDDEN,
	TB_ISBUTTONINDETERMINATE, // = WM_USER + 13,
	TB_SETSTATE              = WM_USER + 17,
	TB_GETSTATE              = WM_USER + 18,
	TB_ADDBITMAP             = WM_USER + 19,
	TB_DELETEBUTTON          = WM_USER + 22,
	TB_GETBUTTON,
	TB_BUTTONCOUNT,
	TB_COMMANDTOINDEX,
	TB_SAVERESTOREA,
	TB_CUSTOMIZE,
	TB_ADDSTRINGA,
	TB_GETITEMRECT,
	TB_BUTTONSTRUCTSIZE,
	TB_SETBUTTONSIZE,
	TB_SETBITMAPSIZE,
	TB_AUTOSIZE, //          = WM_USER + 33,
	TB_GETTOOLTIPS           = WM_USER + 35,
	TB_SETTOOLTIPS           = WM_USER + 36,
	TB_SETPARENT             = WM_USER + 37,
	TB_SETROWS               = WM_USER + 39,
	TB_GETROWS,
	TB_GETBITMAPFLAGS,
	TB_SETCMDID,
	TB_CHANGEBITMAP,
	TB_GETBITMAP,
	TB_GETBUTTONTEXTA,
	TB_REPLACEBITMAP, //     = WM_USER + 46,
	TB_GETBUTTONSIZE         = WM_USER + 58,
	TB_SETBUTTONWIDTH        = WM_USER + 59,
	TB_GETBUTTONTEXTW        = WM_USER + 75,
	TB_SAVERESTOREW          = WM_USER + 76,
	TB_ADDSTRINGW            = WM_USER + 77,
}

extern(Windows)
BOOL EnumChildWindows(HWND, WNDENUMPROC, LPARAM);

alias extern(Windows) BOOL function (HWND, LPARAM) WNDENUMPROC;


	enum {
		TB_SETINDENT = WM_USER + 47,
		TB_SETIMAGELIST,
		TB_GETIMAGELIST,
		TB_LOADIMAGES,
		TB_GETRECT,
		TB_SETHOTIMAGELIST,
		TB_GETHOTIMAGELIST,
		TB_SETDISABLEDIMAGELIST,
		TB_GETDISABLEDIMAGELIST,
		TB_SETSTYLE,
		TB_GETSTYLE,
		//TB_GETBUTTONSIZE,
		//TB_SETBUTTONWIDTH,
		TB_SETMAXTEXTROWS,
		TB_GETTEXTROWS // = WM_USER + 61
	}

enum {
	CCM_FIRST            = 0x2000,
	CCM_LAST             = CCM_FIRST + 0x200,
	CCM_SETBKCOLOR       = 8193,
	CCM_SETCOLORSCHEME   = 8194,
	CCM_GETCOLORSCHEME   = 8195,
	CCM_GETDROPTARGET    = 8196,
	CCM_SETUNICODEFORMAT = 8197,
	CCM_GETUNICODEFORMAT = 8198,
	CCM_SETVERSION       = 0x2007,
	CCM_GETVERSION       = 0x2008,
	CCM_SETNOTIFYWINDOW  = 0x2009
}


enum {
	PBM_SETRANGE     = WM_USER + 1,
	PBM_SETPOS,
	PBM_DELTAPOS,
	PBM_SETSTEP,
	PBM_STEPIT,   // = WM_USER + 5
	PBM_SETRANGE32   = 1030,
	PBM_GETRANGE,
	PBM_GETPOS,
	PBM_SETBARCOLOR, // = 1033
	PBM_SETBKCOLOR   = CCM_SETBKCOLOR
}

enum {
	PBS_SMOOTH   = 1,
	PBS_VERTICAL = 4
}

enum {
        ICC_LISTVIEW_CLASSES = 1,
        ICC_TREEVIEW_CLASSES = 2,
        ICC_BAR_CLASSES      = 4,
        ICC_TAB_CLASSES      = 8,
        ICC_UPDOWN_CLASS     = 16,
        ICC_PROGRESS_CLASS   = 32,
        ICC_HOTKEY_CLASS     = 64,
        ICC_ANIMATE_CLASS    = 128,
        ICC_WIN95_CLASSES    = 255,
        ICC_DATE_CLASSES     = 256,
        ICC_USEREX_CLASSES   = 512,
        ICC_COOL_CLASSES     = 1024,
	ICC_STANDARD_CLASSES = 0x00004000,
}

	enum WM_USER = 1024;
}

version(win32_widgets)
	pragma(lib, "comdlg32");


///
enum GenericIcons : ushort {
	None, ///
	// these happen to match the win32 std icons numerically if you just subtract one from the value
	Cut, ///
	Copy, ///
	Paste, ///
	Undo, ///
	Redo, ///
	Delete, ///
	New, ///
	Open, ///
	Save, ///
	PrintPreview, ///
	Properties, ///
	Help, ///
	Find, ///
	Replace, ///
	Print, ///
}

///
void getOpenFileName(
	void delegate(string) onOK,
	string prefilledName = null,
	string[] filters = null
)
{
	return getFileName(true, onOK, prefilledName, filters);
}

///
void getSaveFileName(
	void delegate(string) onOK,
	string prefilledName = null,
	string[] filters = null
)
{
	return getFileName(false, onOK, prefilledName, filters);
}

void getFileName(
	bool openOrSave,
	void delegate(string) onOK,
	string prefilledName = null,
	string[] filters = null,
)
{

	version(win32_widgets) {
		import core.sys.windows.commdlg;
	/*
	Ofn.lStructSize = sizeof(OPENFILENAME); 
	Ofn.hwndOwner = hWnd; 
	Ofn.lpstrFilter = szFilter; 
	Ofn.lpstrFile= szFile; 
	Ofn.nMaxFile = sizeof(szFile)/ sizeof(*szFile); 
	Ofn.lpstrFileTitle = szFileTitle; 
	Ofn.nMaxFileTitle = sizeof(szFileTitle); 
	Ofn.lpstrInitialDir = (LPSTR)NULL; 
	Ofn.Flags = OFN_SHOWHELP | OFN_OVERWRITEPROMPT; 
	Ofn.lpstrTitle = szTitle; 
	 */


		wchar[1024] file = 0;
		makeWindowsString(prefilledName, file[]);
		OPENFILENAME ofn;
		ofn.lStructSize = ofn.sizeof;
		ofn.lpstrFile = file.ptr;
		ofn.nMaxFile = file.length;
		if(openOrSave ? GetOpenFileName(&ofn) : GetSaveFileName(&ofn)) {
			onOK(makeUtf8StringFromWindowsString(ofn.lpstrFile));
		}
	} else version(custom_widgets) {
		auto picker = new FilePicker(prefilledName);
		picker.onOK = onOK;
		picker.show();
	}
}

version(custom_widgets)
private
class FilePicker : Dialog {
	void delegate(string) onOK;
	LineEdit lineEdit;
	this(string prefilledName, Window owner = null) {
		super(300, 200, "Choose File..."); // owner);

		auto listWidget = new ListWidget(this);

		lineEdit = new LineEdit(this);
		lineEdit.focus();
		lineEdit.addEventListener(delegate(CharEvent event) {
			if(event.character == '\t' || event.character == '\n')
				event.preventDefault();
		});

		listWidget.addEventListener(EventType.change, () {
			foreach(o; listWidget.options)
				if(o.selected)
					lineEdit.content = o.label;
		});

		//version(none)
		lineEdit.addEventListener((KeyDownEvent event) {
			if(event.key == Key.Tab) {
				listWidget.clear();

				string commonPrefix;
				auto cnt = lineEdit.content;
				if(cnt.length >= 2 && cnt[0 ..2] == "./")
					cnt = cnt[2 .. $];

				version(Windows) {
					WIN32_FIND_DATA data;
					WCharzBuffer search = WCharzBuffer("./" ~ cnt ~ "*");
					auto handle = FindFirstFileW(search.ptr, &data);
					scope(exit) if(handle !is INVALID_HANDLE_VALUE) FindClose(handle);
					if(handle is INVALID_HANDLE_VALUE) {
						if(GetLastError() == ERROR_FILE_NOT_FOUND)
							goto file_not_found;
						throw new WindowsApiException("FindFirstFileW");
					}
				} else version(Posix) {
					import core.sys.posix.dirent;
					auto dir = opendir(".");
					scope(exit)
						if(dir) closedir(dir);
					if(dir is null)
						throw new ErrnoApiException("opendir");

					auto dirent = readdir(dir);
					if(dirent is null)
						goto file_not_found;
					// filter those that don't start with it, since posix doesn't
					// do the * thing itself
					while(dirent.d_name[0 .. cnt.length] != cnt[]) {
						dirent = readdir(dir);
						if(dirent is null)
							goto file_not_found;
					}
				} else static assert(0);

				while(true) {
				//foreach(string name; dirEntries(".", cnt ~ "*", SpanMode.shallow)) {
					version(Windows) {
						string name = makeUtf8StringFromWindowsString(data.cFileName[0 .. findIndexOfZero(data.cFileName[])]);
					} else version(Posix) {
						string name = dirent.d_name[0 .. findIndexOfZero(dirent.d_name[])].idup;
					} else static assert(0);


					listWidget.addOption(name);
					if(commonPrefix is null)
						commonPrefix = name;
					else {
						foreach(idx, char i; name) {
							if(idx >= commonPrefix.length || i != commonPrefix[idx]) {
								commonPrefix = commonPrefix[0 .. idx];
								break;
							}
						}
					}

					version(Windows) {
						auto ret = FindNextFileW(handle, &data);
						if(ret == 0) {
							if(GetLastError() == ERROR_NO_MORE_FILES)
								break;
							throw new WindowsApiException("FindNextFileW");
						}
					} else version(Posix) {
						dirent = readdir(dir);
						if(dirent is null)
							break;

						while(dirent.d_name[0 .. cnt.length] != cnt[]) {
							dirent = readdir(dir);
							if(dirent is null)
								break;
						}

						if(dirent is null)
							break;
					} else static assert(0);
				}
				if(commonPrefix.length)
					lineEdit.content = commonPrefix;

				file_not_found:
				event.preventDefault();
			}
		});

		lineEdit.content = prefilledName;

		auto hl = new HorizontalLayout(this);
		auto cancelButton = new Button("Cancel", hl);
		auto okButton = new Button("OK", hl);

		recomputeChildLayout(); // FIXME hack

		cancelButton.addEventListener(EventType.triggered, &Cancel);
		okButton.addEventListener(EventType.triggered, &OK);

		this.addEventListener((KeyDownEvent event) {
			if(event.key == Key.Enter || event.key == Key.PadEnter) {
				event.preventDefault();
				OK();
			}
			if(event.key == Key.Escape)
				Cancel();
		});

	}

	override void OK() {
		if(onOK)
			onOK(lineEdit.content);
		close();
	}
}

/*
http://msdn.microsoft.com/en-us/library/windows/desktop/bb775947%28v=vs.85%29.aspx#check_boxes
http://msdn.microsoft.com/en-us/library/windows/desktop/ms633574%28v=vs.85%29.aspx
http://msdn.microsoft.com/en-us/library/windows/desktop/bb775943%28v=vs.85%29.aspx
http://msdn.microsoft.com/en-us/library/windows/desktop/bb775951%28v=vs.85%29.aspx
http://msdn.microsoft.com/en-us/library/windows/desktop/ms632680%28v=vs.85%29.aspx
http://msdn.microsoft.com/en-us/library/windows/desktop/ms644996%28v=vs.85%29.aspx#message_box
http://www.sbin.org/doc/Xlib/chapt_03.html

http://msdn.microsoft.com/en-us/library/windows/desktop/bb760433%28v=vs.85%29.aspx
http://msdn.microsoft.com/en-us/library/windows/desktop/bb760446%28v=vs.85%29.aspx
http://msdn.microsoft.com/en-us/library/windows/desktop/bb760443%28v=vs.85%29.aspx
http://msdn.microsoft.com/en-us/library/windows/desktop/bb760476%28v=vs.85%29.aspx
*/


// These are all for setMenuAndToolbarFromAnnotatedCode
/// This item in the menu will be preceded by a separator line
/// Group: generating_from_code
struct separator {}
deprecated("It was misspelled, use separator instead") alias seperator = separator;
/// Program-wide keyboard shortcut to trigger the action
/// Group: generating_from_code
struct accelerator { string keyString; }
/// tells which menu the action will be on
/// Group: generating_from_code
struct menu { string name; }
/// Describes which toolbar section the action appears on
/// Group: generating_from_code
struct toolbar { string groupName; }
///
/// Group: generating_from_code
struct icon { ushort id; }
///
/// Group: generating_from_code
struct label { string label; }
///
/// Group: generating_from_code
struct hotkey { dchar ch; }
///
/// Group: generating_from_code
struct tip { string tip; }


/++
	Observes and allows inspection of an object via automatic gui
+/
/// Group: generating_from_code
ObjectInspectionWindow objectInspectionWindow(T)(T t) if(is(T == class)) {
	return new ObjectInspectionWindowImpl!(T)(t);
}

class ObjectInspectionWindow : Window {
	this(int a, int b, string c) {
		super(a, b, c);
	}

	abstract void readUpdatesFromObject();
}

class ObjectInspectionWindowImpl(T) : ObjectInspectionWindow {
	T t;
	this(T t) {
		this.t = t;

		super(300, 400, "ObjectInspectionWindow - " ~ T.stringof);

		foreach(memberName; __traits(derivedMembers, T)) {{
			alias member = I!(__traits(getMember, t, memberName))[0];
			alias type = typeof(member);
			static if(is(type == int)) {
				auto le = new LabeledLineEdit(memberName ~ ": ", this);
				//le.addEventListener("char", (Event ev) {
					//if((ev.character < '0' || ev.character > '9') && ev.character != '-')
						//ev.preventDefault();
				//});
				le.addEventListener(EventType.change, (Event ev) {
					__traits(getMember, t, memberName) = cast(type) stringToLong(ev.stringValue);
				});

				updateMemberDelegates[memberName] = () {
					le.content = toInternal!string(__traits(getMember, t, memberName));
				};
			}
		}}
	}

	void delegate()[string] updateMemberDelegates;

	override void readUpdatesFromObject() {
		foreach(k, v; updateMemberDelegates)
			v();
	}
}

/++
	Creates a dialog based on a data structure.

	---
	dialog((YourStructure value) {
		// the user filled in the struct and clicked OK,
		// you can check the members now
	});
	---
+/
/// Group: generating_from_code
void dialog(T)(void delegate(T) onOK, void delegate() onCancel = null, string title = T.stringof) {
	auto dg = new AutomaticDialog!T(onOK, onCancel, title);
	dg.show();
}

private static template I(T...) { alias I = T; }


private string beautify(string name, char space = ' ', bool allLowerCase = false) {
	if(name == "id")
		return allLowerCase ? name : "ID";

	char[160] buffer;
	int bufferIndex = 0;
	bool shouldCap = true;
	bool shouldSpace;
	bool lastWasCap;
	foreach(idx, char ch; name) {
		if(bufferIndex == buffer.length) return name; // out of space, just give up, not that important

		if((ch >= 'A' && ch <= 'Z') || ch == '_') {
			if(lastWasCap) {
				// two caps in a row, don't change. Prolly acronym.
			} else {
				if(idx)
					shouldSpace = true; // new word, add space
			}

			lastWasCap = true;
		} else {
			lastWasCap = false;
		}

		if(shouldSpace) {
			buffer[bufferIndex++] = space;
			if(bufferIndex == buffer.length) return name; // out of space, just give up, not that important
			shouldSpace = false;
		}
		if(shouldCap) {
			if(ch >= 'a' && ch <= 'z')
				ch -= 32;
			shouldCap = false;
		}
		if(allLowerCase && ch >= 'A' && ch <= 'Z')
			ch += 32;
		buffer[bufferIndex++] = ch;
	}
	return buffer[0 .. bufferIndex].idup;
}

/++
	This is the implementation for [dialog]. None of its details are guaranteed stable and may change at any time; the stable interface is just the [dialog] function at this time.
+/
class AutomaticDialog(T) : Dialog {
	T t;

	void delegate(T) onOK;
	void delegate() onCancel;

	override int paddingTop() { return Window.lineHeight; }
	override int paddingBottom() { return Window.lineHeight; }
	override int paddingRight() { return Window.lineHeight; }
	override int paddingLeft() { return Window.lineHeight; }

	this(void delegate(T) onOK, void delegate() onCancel, string title) {
		assert(onOK !is null);
		static if(is(T == class))
			t = new T();
		this.onOK = onOK;
		this.onCancel = onCancel;
		super(400, cast(int)(__traits(allMembers, T).length * 2) * (Window.lineHeight + 4 + 2) + Window.lineHeight + 56, title);

		static if(is(T == class))
			this.addDataControllerWidget(t);
		else
			this.addDataControllerWidget(&t);

		auto hl = new HorizontalLayout(this);
		auto stretch = new HorizontalSpacer(hl); // to right align
		auto ok = new CommandButton("OK", hl);
		auto cancel = new CommandButton("Cancel", hl);
		ok.addEventListener(EventType.triggered, &OK);
		cancel.addEventListener(EventType.triggered, &Cancel);

		this.addEventListener((KeyDownEvent ev) {
			if(ev.key == Key.Enter || ev.key == Key.PadEnter) {
				ok.focus();
				OK();
				ev.preventDefault();
			}
			if(ev.key == Key.Escape) {
				Cancel();
				ev.preventDefault();
			}
		});

		//this.children[0].focus();
	}

	override void OK() {
		onOK(t);
		close();
	}

	override void Cancel() {
		if(onCancel)
			onCancel();
		close();
	}
}

private template baseClassCount(Class) {
	private int helper() {
		int count = 0;
		static if(is(Class bases == super)) {
			foreach(base; bases)
				static if(is(base == class))
					count += 1 + baseClassCount!base;
		}
		return count;
	}

	enum int baseClassCount = helper();
}

private long stringToLong(string s) {
	long ret;
	if(s.length == 0)
		return ret;
	bool negative = s[0] == '-';
	if(negative)
		s = s[1 .. $];
	foreach(ch; s) {
		if(ch >= '0' && ch <= '9') {
			ret *= 10;
			ret += ch - '0';
		}
	}
	if(negative)
		ret = -ret;
	return ret;
}


interface ReflectableProperties {
	/++
		Iterates the event's properties as strings. Note that keys may be repeated and a get property request may
		call your sink with `null`. It it does, it means the key either doesn't request or cannot be represented by
		json in the current implementation.

		This is auto-implemented for you if you mixin [RegisterGetters] in your child classes and only have
		properties of type `bool`, `int`, `double`, or `string`. For other ones, you will need to do it yourself
		as of the June 2, 2021 release.

		History:
			Added June 2, 2021.

		See_Also: [getPropertyAsString], [setPropertyFromString]
	+/
	void getPropertiesList(scope void delegate(string name) sink) const;// @nogc pure nothrow;
	/++
		Requests a property to be delivered to you as a string, through your `sink` delegate.

		If the `value` is null, it means the property could not be retreived. If `valueIsJson`, it should
		be interpreted as json, otherwise, it is just a plain string.

		The sink should always be called exactly once for each call (it is basically a return value, but it might
		use a local buffer it maintains instead of allocating a return value).

		History:
			Added June 2, 2021.

		See_Also: [getPropertiesList], [setPropertyFromString]
	+/
	void getPropertyAsString(string name, scope void delegate(string name, scope const(char)[] value, bool valueIsJson) sink);
	/++
		Sets the given property, if it exists, to the given value, if possible. If `strIsJson` is true, it will json decode (if the implementation wants to) then apply the value, otherwise it will treat it as a plain string.

		History:
			Added June 2, 2021.

		See_Also: [getPropertiesList], [getPropertyAsString], [SetPropertyResult]
	+/
	SetPropertyResult setPropertyFromString(string name, scope const(char)[] str, bool strIsJson);

	/// [setPropertyFromString] possible return values
	enum SetPropertyResult {
		success = 0, /// the property has been successfully set to the request value
		notPermitted = -1, /// the property exists but it cannot be changed at this time
		notImplemented = -2, /// the set function is not implemented for the given property (which may or may not exist)
		noSuchProperty = -3, /// there is no property by that name
		wrongFormat = -4, /// the string was given in the wrong format, e.g. passing "two" for an int value
		invalidValue = -5, /// the string is in the correct format, but the specific given value could not be used (for example, because it was out of bounds)
	}

	/++
		You can mix this in to get an implementation in child classes. This does [setPropertyFromString].

		Your original base class, however, must implement its own methods. I recommend doing the initial ones by hand.

		For [Widget] and [Event], the library provides [Widget.Register] and [Event.Register] that call these for you, so you should
		rarely need to use these building blocks directly.
	+/
	mixin template RegisterSetters() {
		override SetPropertyResult setPropertyFromString(string name, scope const(char)[] value, bool valueIsJson) {
			switch(name) {
				foreach(memberName; __traits(derivedMembers, typeof(this))) {
					case memberName:
						static if(is(typeof(__traits(getMember, this, memberName)) : const bool)) {
							if(value != "true" && value != "false")
								return SetPropertyResult.wrongFormat;
							__traits(getMember, this, memberName) = value == "true" ? true : false;
							return SetPropertyResult.success;
						} else static if(is(typeof(__traits(getMember, this, memberName)) : const long)) {
							import core.stdc.stdlib;
							char[128] zero = 0;
							if(buffer.length + 1 >= zero.length)
								return SetPropertyResult.wrongFormat;
							zero[0 .. buffer.length] = buffer[];
							__traits(getMember, this, memberName) = strtol(buffer.ptr, null, 10);
						} else static if(is(typeof(__traits(getMember, this, memberName)) : const double)) {
							import core.stdc.stdlib;
							char[128] zero = 0;
							if(buffer.length + 1 >= zero.length)
								return SetPropertyResult.wrongFormat;
							zero[0 .. buffer.length] = buffer[];
							__traits(getMember, this, memberName) = strtod(buffer.ptr, null, 10);
						} else static if(is(typeof(__traits(getMember, this, memberName)) : const string)) {
							__traits(getMember, this, memberName) = value.idup;
						} else {
							return SetPropertyResult.notImplemented;
						}

				}
				default:
					return super.setPropertyFromString(name, value, valueIsJson);
			}
		}
	}

	/++
		You can mix this in to get an implementation in child classes. This does [getPropertyAsString] and [getPropertiesList].

		Your original base class, however, must implement its own methods. I recommend doing the initial ones by hand.

		For [Widget] and [Event], the library provides [Widget.Register] and [Event.Register] that call these for you, so you should
		rarely need to use these building blocks directly.
	+/
	mixin template RegisterGetters() {
		override void getPropertiesList(scope void delegate(string name) sink) const {
			super.getPropertiesList(sink);

			foreach(memberName; __traits(derivedMembers, typeof(this))) {
				sink(memberName);
			}
		}
		override void getPropertyAsString(string name, scope void delegate(string name, scope const(char)[] value, bool valueIsJson) sink) {
			switch(name) {
				foreach(memberName; __traits(derivedMembers, typeof(this))) {
					case memberName:
						static if(is(typeof(__traits(getMember, this, memberName)) : const bool)) {
							sink(name, __traits(getMember, this, memberName) ? "true" : "false", true);
						} else static if(is(typeof(__traits(getMember, this, memberName)) : const long)) {
							import core.stdc.stdio;
							char[32] buffer;
							auto len = snprintf(buffer.ptr, buffer.length, "%lld", cast(long) __traits(getMember, this, memberName));
							sink(name, buffer[0 .. len], true);
						} else static if(is(typeof(__traits(getMember, this, memberName)) : const double)) {
							import core.stdc.stdio;
							char[32] buffer;
							auto len = snprintf(buffer.ptr, buffer.length, "%f", cast(double) __traits(getMember, this, memberName));
							sink(name, buffer[0 .. len], true);
						} else static if(is(typeof(__traits(getMember, this, memberName)) : const string)) {
							sink(name, __traits(getMember, this, memberName), false);
							//sinkJsonString(memberName, __traits(getMember, this, memberName), sink);
						} else {
							sink(name, null, true);
						}

					return;
				}
				default:
					return super.getPropertyAsString(name, sink);
			}
		}
	}
}


/+

	I could fix up the hierarchy kinda like this

	class Widget {
		Widget[] children() { return null; }
	}
	interface WidgetContainer {
		Widget asWidget();
		void addChild(Widget w);

		// alias asWidget this; // but meh
	}

	Widget can keep a (Widget parent) ctor, but it should prolly deprecate and tell people to instead change their ctors to take WidgetContainer instead.

	class Layout : Widget, WidgetContainer {}

	class Window : WidgetContainer {}


	All constructors that previously took Widgets should now take WidgetContainers instead



	But I'm kinda meh toward it, im not sure this is a real problem even though there are some addChild things that throw "plz don't".
+/

/+
	LAYOUTS 2.0

	can just be assigned as a function. assigning a new one will cause it to be immediately called.

	they simply are responsible for the recomputeChildLayout. If this pointer is null, it uses the default virtual one.

	recomputeChildLayout only really needs a property accessor proxy... just the layout info too.

	and even Paint can just use computedStyle...

		background color
		font
		border color and style

	And actually the style proxy can offer some helper routines to draw these like the draw 3d box
		please note that many widgets and in some modes will completely ignore properties as they will.
		they are just hints you set, not promises.





	So generally the existing virtual functions are just the default for the class. But individual objects
	or stylesheets can override this. The virtual ones count as tag-level specificity in css.
+/

/++
	Structure to represent a collection of background hints. New features can be added here, so make sure you use the provided constructors and factories for maximum compatibility.

	History:
		Added May 24, 2021.
+/
struct WidgetBackground {
	/++
		A background with the given solid color.
	+/
	this(Color color) {
		this.color = color;
	}

	this(WidgetBackground bg) {
		this = bg;
	}

	/++
		Creates a widget from the string.

		Currently, it only supports solid colors via [Color.fromString], but it will likely be expanded in the future to something more like css.
	+/
	static WidgetBackground fromString(string s) {
		return WidgetBackground(Color.fromString(s));
	}

	private Color color;
}

/++
	Interface to a custom visual theme which is able to access and use style hint properties, draw stylistic elements, and even completely override existing class' paint methods (though I'd note that can be a lot harder than it may seem due to the various little details of state you need to reflect visually, so that should be your last result!)

	Please note that this is only guaranteed to be used by custom widgets, and custom widgets are generally inferior to system widgets. Layout properties may be used by sytstem widgets though.

	You should not inherit from this directly, but instead use [VisualTheme].

	History:
		Added May 8, 2021
+/
abstract class BaseVisualTheme {
	/// Don't implement this, instead use [VisualTheme] and implement `paint` methods on specific subclasses you want to override.
	abstract void doPaint(Widget widget, WidgetPainter painter);

	/+
	/// Don't implement this, instead use [VisualTheme] and implement `StyleOverride` aliases on specific subclasses you want to override.
	abstract void useStyleProperties(Widget w, scope void delegate(scope Widget.Style props) dg);
	+/

	/++
		Returns the property as a string, or null if it was not overridden in the style definition. The idea here is something like css,
		where the interpretation of the string varies for each property and may include things like measurement units.
	+/
	abstract string getPropertyString(Widget widget, string propertyName);

	/++
		Default background color of the window. Widgets also use this to simulate transparency.

		Probably some shade of grey.
	+/
	abstract Color windowBackgroundColor();
	abstract Color widgetBackgroundColor();
	abstract Color foregroundColor();
	abstract Color lightAccentColor();
	abstract Color darkAccentColor();

	/++
		Color used to indicate active selections in lists and text boxes, etc.
	+/
	abstract Color selectionColor();

	abstract OperatingSystemFont defaultFont();

	private OperatingSystemFont defaultFontCache_;
	private bool defaultFontCachePopulated;
	private OperatingSystemFont defaultFontCached() {
		if(!defaultFontCachePopulated) {
			// FIXME: set this to false if X disconnect or if visual theme changes
			defaultFontCache_ = defaultFont();
			defaultFontCachePopulated = true;
		}
		return defaultFontCache_;
	}
}

/+
	A widget should have:
		classList
		dataset
		attributes
		computedStyles
		state (persistent)
		dynamic state (focused, hover, etc)
+/

// visualTheme.computedStyle(this).paddingLeft


/++
	This is your entry point to create your own visual theme for custom widgets.
+/
abstract class VisualTheme(CRTP) : BaseVisualTheme {
	override string getPropertyString(Widget widget, string propertyName) {
		return null;
	}

	/+
		mixin StyleOverride!Widget
	final override void useStyleProperties(Widget w, scope void delegate(scope Widget.Style props) dg) {
		w.useStyleProperties(dg);
	}
	+/

	final override void doPaint(Widget widget, WidgetPainter painter) {
		auto derived = cast(CRTP) cast(void*) this;

		scope void delegate(Widget, WidgetPainter) bestMatch;
		int bestMatchScore;

		static if(__traits(hasMember, CRTP, "paint"))
		foreach(overload; __traits(getOverloads, CRTP, "paint")) {
			static if(is(typeof(overload) Params == __parameters)) {
				static assert(Params.length == 2);
				static assert(is(Params[0] : Widget));
				static assert(is(Params[1] == WidgetPainter));
				static assert(is(typeof(&__traits(child, derived, overload)) == delegate), "Found a paint method that doesn't appear to be a delegate. One cause of this can be your dmd being too old, make sure it is version 2.094 or newer to use this feature."); // , __traits(getLocation, overload).stringof ~ " is not a delegate " ~ typeof(&__traits(child, derived, overload)).stringof);

				alias type = Params[0];
				if(cast(type) widget) {
					auto score = baseClassCount!type;

					if(score > bestMatchScore) {
						bestMatch = cast(typeof(bestMatch)) &__traits(child, derived, overload);
						bestMatchScore = score;
					}
				}
			} else static assert(0, "paint should be a method.");
		}

		if(bestMatch)
			bestMatch(widget, painter);
		else
			widget.paint(painter);
	}

	// I have to put these here even though I kinda don't want to since dmd regressed on detecting unimplemented interface functions through abstract classes
	override Color windowBackgroundColor() { return Color(212, 212, 212); }
	override Color widgetBackgroundColor() { return Color.white; }
	override Color foregroundColor() { return Color.black; }
	override Color darkAccentColor() { return Color(172, 172, 172); }
	override Color lightAccentColor() { return Color(223, 223, 223); }
	override Color selectionColor() { return Color(0, 0, 128); }
	override OperatingSystemFont defaultFont() { return null; } // will just use the default out of simpledisplay's xfontstr

	private static struct Cached {
		// i prolly want to do this
	}
}

final class DefaultVisualTheme : VisualTheme!DefaultVisualTheme {
	/+
	OperatingSystemFont defaultFont() { return new OperatingSystemFont("Times New Roman", 8, FontWeight.medium); }
	Color windowBackgroundColor() { return Color(242, 242, 242); }
	Color darkAccentColor() { return windowBackgroundColor; }
	Color lightAccentColor() { return windowBackgroundColor; }
	+/
}

// still do layout delegation
// and... split off Window from Widget.
