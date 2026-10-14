#pragma once

#include "GamepadInputTypes.h"
#include <cstdint>

class InputSystem
{
public:
	InputSystem();
	~InputSystem();

	InputSystem( const InputSystem& ) = delete;
	InputSystem& operator=( const InputSystem& ) = delete;
	InputSystem( InputSystem&& ) = delete;
	InputSystem& operator=( InputSystem&& ) = delete;

	bool QueryGamepadButtonState( Input::GamepadButtons button, Input::InputAction action ) const;
	bool IsGamepadConnected() const;
	void Update();
	void ApplyVibrationEffect( uint32_t motorSpeed );

private:
	struct PlatformState;

	PlatformState* m_platformState;
	uint16_t m_previousButtons;
	uint16_t m_currentButtons;
	bool m_isGamepadConnected;
};