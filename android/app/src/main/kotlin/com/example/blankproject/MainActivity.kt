package com.example.blankproject

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.blankproject/shake"
    private val EVENT_CHANNEL = "com.example.blankproject/shake_event"
    
    private lateinit var sensorManager: SensorManager
    private var accelerometer: Sensor? = null
    private lateinit var shakeDetector: ShakeDetector
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        shakeDetector = ShakeDetector(::onShakeDetected)
        
        // Setup method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startShakeDetection" -> {
                    startShakeDetection()
                    result.success(null)
                }
                "stopShakeDetection" -> {
                    stopShakeDetection()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        
        // Setup event channel
        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).apply {
            setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    eventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
        }
    }

    private fun startShakeDetection() {
        accelerometer?.let {
            sensorManager.registerListener(shakeDetector, it, SensorManager.SENSOR_DELAY_UI)
        }
    }

    private fun stopShakeDetection() {
        sensorManager.unregisterListener(shakeDetector)
    }

    private fun onShakeDetected() {
        eventSink?.success("shake_detected")
    }

    inner class ShakeDetector(private val onShake: () -> Unit) : SensorEventListener {
        private val shakeThreshold = 25f
        private val minTimeBetweenShakes = 2000L // 2 seconds
        private var lastShakeTime = 0L
        private var lastX = 0f
        private var lastY = 0f
        private var lastZ = 0f

        override fun onSensorChanged(event: SensorEvent) {
            val currentTime = System.currentTimeMillis()
            if (currentTime - lastShakeTime < minTimeBetweenShakes) return

            val x = event.values[0]
            val y = event.values[1]
            val z = event.values[2]

            val deltaX = Math.abs(x - lastX)
            val deltaY = Math.abs(y - lastY)
            val deltaZ = Math.abs(z - lastZ)

            if ((deltaX > shakeThreshold && deltaY > shakeThreshold) || 
                (deltaX > shakeThreshold && deltaZ > shakeThreshold) || 
                (deltaY > shakeThreshold && deltaZ > shakeThreshold)) {
                lastShakeTime = currentTime
                onShake()
            }

            lastX = x
            lastY = y
            lastZ = z
        }

        override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}
    }
}