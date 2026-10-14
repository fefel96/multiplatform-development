#include "InputSystemAPI.h"

#include <cstdio>
#include <limits>

#if defined(PLATFORM_WINDOWS)
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <Windows.h>
#include <Xinput.h>

#pragma comment(lib, "Xinput.lib")
#elif defined(PLATFORM_PROSPERO)
#error "The Prospero input backend is not implemented yet. See the PS5 preparation notes in README.md."
#else
#error "InputSystem requires either PLATFORM_WINDOWS or PLATFORM_PROSPERO."
#endif

namespace
{
	constexpr unsigned int GAMEPAD_BUTTON_COUNT = 10;

	uint16_t GetButtonMask( Input::GamepadButtons button )
	{
		const unsigned int buttonIndex = static_cast<unsigned int>( button );
		if ( buttonIndex >= GAMEPAD_BUTTON_COUNT )
		{
			return 0;
		}

		return static_cast<uint16_t>( 1u << buttonIndex );
	}

#if defined(PLATFORM_WINDOWS)
	uint16_t GetXInputButtons( WORD buttons )
	{
		uint16_t result = 0;

		if ( ( buttons & XINPUT_GAMEPAD_Y ) != 0 )
			result |= GetButtonMask( Input::GamepadButtons::FACE_BUTTON_TOP );
		if ( ( buttons & XINPUT_GAMEPAD_A ) != 0 )
			result |= GetButtonMask( Input::GamepadButtons::FACE_BUTTON_DOWN );
		if ( ( buttons & XINPUT_GAMEPAD_X ) != 0 )
			result |= GetButtonMask( Input::GamepadButtons::FACE_BUTTON_LEFT );
		if ( ( buttons & XINPUT_GAMEPAD_B ) != 0 )
			result |= GetButtonMask( Input::GamepadButtons::FACE_BUTTON_RIGHT );

		if ( ( buttons & XINPUT_GAMEPAD_DPAD_UP ) != 0 )
			result |= GetButtonMask( Input::GamepadButtons::DPAD_TOP );
		if ( ( buttons & XINPUT_GAMEPAD_DPAD_DOWN ) != 0 )
			result |= GetButtonMask( Input::GamepadButtons::DPAD_DOWN );
		if ( ( buttons & XINPUT_GAMEPAD_DPAD_LEFT ) != 0 )
			result |= GetButtonMask( Input::GamepadButtons::DPAD_LEFT );
		if ( ( buttons & XINPUT_GAMEPAD_DPAD_RIGHT ) != 0 )
			result |= GetButtonMask( Input::GamepadButtons::DPAD_RIGHT );

		if ( ( buttons & XINPUT_GAMEPAD_LEFT_SHOULDER ) != 0 )
			result |= GetButtonMask( Input::GamepadButtons::SHOULDER_LEFT );
		if ( ( buttons & XINPUT_GAMEPAD_RIGHT_SHOULDER ) != 0 )
			result |= GetButtonMask( Input::GamepadButtons::SHOULDER_RIGHT );

		return result;
	}
#endif
}

struct InputSystem::PlatformState
{
#if defined(PLATFORM_WINDOWS)
	DWORD controllerIndex;
#endif
};

InputSystem::InputSystem()
	: m_platformState( new PlatformState() )
	, m_previousButtons( 0 )
	, m_currentButtons( 0 )
	, m_isGamepadConnected( false )
{
#if defined(PLATFORM_WINDOWS)
	m_platformState->controllerIndex = 0;
#endif
}

InputSystem::~InputSystem()
{
	if ( m_isGamepadConnected )
	{
		ApplyVibrationEffect( 0 );
	}
	delete m_platformState;
}

bool InputSystem::QueryGamepadButtonState( Input::GamepadButtons button, Input::InputAction action ) const
{
	const uint16_t buttonMask = GetButtonMask( button );
	if ( buttonMask == 0 )
	{
		return false;
	}

	const bool wasPressed = ( m_previousButtons & buttonMask ) != 0;
	const bool isPressed = ( m_currentButtons & buttonMask ) != 0;

	switch ( action )
	{
	case Input::InputAction::BUTTON_HOLD:
		return isPressed;
	case Input::InputAction::BUTTON_PRESSED:
		return isPressed && !wasPressed;
	case Input::InputAction::BUTTON_RELEASED:
		return !isPressed && wasPressed;
	default:
		return false;
	}
}

bool InputSystem::IsGamepadConnected() const
{
	return m_isGamepadConnected;
}

void InputSystem::Update()
{
	m_previousButtons = m_currentButtons;
	m_currentButtons = 0;
	m_isGamepadConnected = false;

#if defined(PLATFORM_WINDOWS)
	XINPUT_STATE state = {};
	const DWORD result = XInputGetState( m_platformState->controllerIndex, &state );
	if ( result == ERROR_SUCCESS )
	{
		m_isGamepadConnected = true;
		m_currentButtons = GetXInputButtons( state.Gamepad.wButtons );
	}
	else if ( result != ERROR_DEVICE_NOT_CONNECTED )
	{
		std::fprintf( stderr, "XInputGetState failed with error %lu.\n", static_cast<unsigned long>( result ) );
	}
#endif
}

void InputSystem::ApplyVibrationEffect( uint32_t motorSpeed )
{
#if defined(PLATFORM_WINDOWS)
	if ( !m_isGamepadConnected )
	{
		return;
	}

	const uint32_t limitedSpeed = motorSpeed > ( std::numeric_limits<WORD>::max )()
		? ( std::numeric_limits<WORD>::max )()
		: motorSpeed;
	XINPUT_VIBRATION vibration = {};
	vibration.wLeftMotorSpeed = static_cast<WORD>( limitedSpeed );
	vibration.wRightMotorSpeed = static_cast<WORD>( limitedSpeed );

	const DWORD result = XInputSetState( m_platformState->controllerIndex, &vibration );
	if ( result == ERROR_DEVICE_NOT_CONNECTED )
	{
		m_isGamepadConnected = false;
		m_previousButtons = m_currentButtons;
		m_currentButtons = 0;
	}
	else if ( result != ERROR_SUCCESS )
	{
		std::fprintf( stderr, "XInputSetState failed with error %lu.\n", static_cast<unsigned long>( result ) );
	}
#else
	(void)motorSpeed;
#endif
}
