#include <cstdio>

#include "input/InputSystemAPI.h"
#include "core/Clock.h"

namespace GameConstants
{
	constexpr float GAME_TICK_RATE = 60.0f;
	constexpr float GAME_TARGET_DELTA = 1000.0f / GAME_TICK_RATE;
}


int main() 
{
	// @note - lukas.vogl - Setting up a basic clock that works on PC and PS4
	Clock::Init();
	Clock clock;
	clock.Start();

	printf("Hello MMP course development project\n");

	#if defined(PLATFORM_WINDOWS)
        std::printf("Hello from Windows!\n");
    #elif defined(PLATFORM_PROSPERO)
        std::printf("Hello from PS5!\n");
    #else
        std::printf("Unknown platform!\n");
    #endif

	/*
	 * The setup of the input system is up to you. It can be initialized after the CTOR
	 * but you can also use `Initialize` methods when it makes sense for your implementation.
	 */
	InputSystem input;
	const Input::GamepadButtons buttons[] =
	{
		Input::GamepadButtons::FACE_BUTTON_TOP,
		Input::GamepadButtons::FACE_BUTTON_DOWN,
		Input::GamepadButtons::FACE_BUTTON_LEFT,
		Input::GamepadButtons::FACE_BUTTON_RIGHT,
		Input::GamepadButtons::DPAD_TOP,
		Input::GamepadButtons::DPAD_DOWN,
		Input::GamepadButtons::DPAD_LEFT,
		Input::GamepadButtons::DPAD_RIGHT,
		Input::GamepadButtons::SHOULDER_LEFT,
		Input::GamepadButtons::SHOULDER_RIGHT
	};
	const char* buttonNames[] = { "Y", "A", "X", "B", "Up", "Down", "Left", "Right", "LB", "RB" };
	const size_t buttonCount = sizeof( buttons ) / sizeof( buttons[0] );
	bool previousButtonStates[sizeof( buttons ) / sizeof( buttons[0] )] = {};
	bool previousConnectionState = false;
	bool hasPrintedInputState = false;
	std::printf("Controller: waiting for input (Ctrl+C to quit)\n");

	// @note - lukas.vogl - Pseudo "game-loop" to simulate we are doing something (will ne necessary for further milestones)
	float passedGameTime = 0.0f;
	bool shouldExitGame = false;
	while ( !shouldExitGame )
	{
		input.Update();

		const bool connected = input.IsGamepadConnected();
		bool currentButtonStates[sizeof( buttons ) / sizeof( buttons[0] )] = {};
		bool inputStateChanged = !hasPrintedInputState || connected != previousConnectionState;
		for ( size_t i = 0; i < buttonCount; ++i )
		{
			currentButtonStates[i] = input.QueryGamepadButtonState( buttons[i], Input::InputAction::BUTTON_HOLD );
			if ( currentButtonStates[i] != previousButtonStates[i] )
			{
				inputStateChanged = true;
			}
		}

		if ( inputStateChanged )
		{
			std::printf("\rController: %s | ", connected ? "CONNECTED" : "DISCONNECTED");
			for ( size_t i = 0; i < buttonCount; ++i )
			{
				std::printf("%s:%s%s", buttonNames[i], currentButtonStates[i] ? "ON " : "off",
					i + 1 == buttonCount ? "" : " ");
			}
			std::printf("  ");
			std::fflush(stdout);
			for ( size_t i = 0; i < buttonCount; ++i )
			{
				previousButtonStates[i] = currentButtonStates[i];
			}
			previousConnectionState = connected;
			hasPrintedInputState = true;
		}

		// @note - lukas.vogl - We want to exit the game when the right button on the gamepad face is pressed ( B on XBox controllers, Circle on Dualshocks )
		if ( input.QueryGamepadButtonState( Input::GamepadButtons::FACE_BUTTON_RIGHT, Input::InputAction::BUTTON_PRESSED ) )
		{
			std::printf("\nB/Circle pressed; exiting.\n");
			shouldExitGame = true;
		}

		// // @note - lukas.vogl - We want to test the vibration feature with the down button (as long as it's hold, we vibrate)
		if ( input.QueryGamepadButtonState( Input::GamepadButtons::FACE_BUTTON_RIGHT, Input::InputAction::BUTTON_HOLD ) )
		{
			input.ApplyVibrationEffect( 20000 );
		}
		else
		{
			input.ApplyVibrationEffect( 0 );
		}

		// @task - lukas.vogl - Add another function here that let's you (and later me) test that your input system reacts to presses, releases and hold actions for the supported buttons

		// @note - lukas.vogl - This is here to simulate a 60HZ game-loop and will later be used to show further optimizations we can do by using threads
		while ( clock.ToMilliseconds() < passedGameTime + GameConstants::GAME_TARGET_DELTA ) { /* busy wait here - not optimal, and not production ready code, but enough for the assignment */ }
		passedGameTime = clock.ToMilliseconds();
	}

	printf("Shutting down ...\n");
}