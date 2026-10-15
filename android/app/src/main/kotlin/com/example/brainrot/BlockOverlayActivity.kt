package com.example.brainrot

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

class BlockOverlayActivity : Activity() {
    
    companion object {
        private const val TAG = "BlockOverlayActivity"
    }
    
    private var blockedPackage: String? = null
    private var blockReason: String? = null
    private var canBypass: Boolean = false
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Make this activity appear over other apps
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
        
        // Get intent data
        blockedPackage = intent.getStringExtra("blocked_package")
        blockReason = intent.getStringExtra("block_reason")
        canBypass = intent.getBooleanExtra("can_bypass", false)
        
        Log.d(TAG, "Showing block screen for: $blockedPackage")
        
        setupUI()
    }
    
    private fun setupUI() {
        // Root container with warm cream background matching Flutter theme
        val rootLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(48, 64, 48, 64)
            setBackgroundColor(Color.parseColor("#FFF8EF"))
        }

        // Inner Card Container
        val cardLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(56, 64, 56, 56)
            background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = 64f
                setColor(Color.WHITE)
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            elevation = 16f
        }
        
        // App icon container (pastel orange circle)
        val iconBadge = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            val sizePx = (80 * resources.displayMetrics.density).toInt()
            layoutParams = LinearLayout.LayoutParams(sizePx, sizePx).apply {
                bottomMargin = 36
            }
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#FFF0E5"))
            }
        }

        val iconView = ImageView(this).apply {
            val innerSize = (48 * resources.displayMetrics.density).toInt()
            layoutParams = LinearLayout.LayoutParams(innerSize, innerSize)
            
            // Try loading app icon dynamically
            var loaded = false
            if (!blockedPackage.isNullOrEmpty()) {
                try {
                    val appIcon = packageManager.getApplicationIcon(blockedPackage!!)
                    setImageDrawable(appIcon)
                    loaded = true
                } catch (e: Exception) {
                    Log.w(TAG, "Could not load icon for $blockedPackage", e)
                }
            }
            if (!loaded) {
                setImageResource(R.mipmap.ic_launcher)
            }
        }
        iconBadge.addView(iconView)
        cardLayout.addView(iconBadge)
        
        // Title
        val titleView = TextView(this).apply {
            text = getString(R.string.block_message_title)
            textSize = 22f
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(Color.parseColor("#2B2927"))
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = 14
            }
        }
        cardLayout.addView(titleView)
        
        // Message / Reason
        val messageView = TextView(this).apply {
            text = blockReason ?: getString(R.string.block_message_default)
            textSize = 15f
            setTextColor(Color.parseColor("#7A736D"))
            gravity = Gravity.CENTER
            setLineSpacing(8f, 1f)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = 40
            }
        }
        cardLayout.addView(messageView)
        
        // Buttons container
        val buttonsLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        
        // OK Button (Primary Action)
        val okButton = Button(this).apply {
            text = getString(R.string.block_button_ok)
            textSize = 15f
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(Color.WHITE)
            background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = 36f
                setColor(Color.parseColor("#F27A3D"))
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                (48 * resources.displayMetrics.density).toInt()
            ).apply {
                bottomMargin = if (canBypass) 16 else 0
            }
            setOnClickListener {
                goToHomeScreen()
                finish()
            }
        }
        buttonsLayout.addView(okButton)
        
        // Emergency Access Button (if allowed)
        if (canBypass) {
            val emergencyButton = Button(this).apply {
                text = getString(R.string.block_button_emergency)
                textSize = 14f
                typeface = Typeface.DEFAULT_BOLD
                setTextColor(Color.parseColor("#F27A3D"))
                background = GradientDrawable().apply {
                    shape = GradientDrawable.RECTANGLE
                    cornerRadius = 36f
                    setColor(Color.parseColor("#FFF0E5"))
                }
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    (46 * resources.displayMetrics.density).toInt()
                )
                setOnClickListener {
                    showEmergencyAccessDialog()
                }
            }
            buttonsLayout.addView(emergencyButton)
        }
        
        cardLayout.addView(buttonsLayout)
        rootLayout.addView(cardLayout)
        setContentView(rootLayout)
    }
    
    private fun showEmergencyAccessDialog() {
        val builder = android.app.AlertDialog.Builder(this)
        builder.setTitle("Quyền truy cập khẩn cấp")
        builder.setMessage("Bạn có chắc chắn cần truy cập khẩn cấp ứng dụng này? Điều này sẽ tạm thời bỏ qua quy tắc chặn.")
        
        builder.setPositiveButton("Đồng ý") { _, _ ->
            Log.d(TAG, "Emergency access granted for: $blockedPackage")
            finish() // Allow the app to continue
        }
        
        builder.setNegativeButton("Hủy") { dialog, _ ->
            dialog.dismiss()
        }
        
        builder.show()
    }
    
    private fun goToHomeScreen() {
        try {
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(homeIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Error going to home screen", e)
        }
    }
    
    override fun onBackPressed() {
        // Prevent back button from bypassing the block
        goToHomeScreen()
        finish()
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        // Handle new intent if the activity is already running
        setIntent(intent)
        
        blockedPackage = intent?.getStringExtra("blocked_package")
        blockReason = intent?.getStringExtra("block_reason")
        canBypass = intent?.getBooleanExtra("can_bypass", false) ?: false
        
        setupUI() // Refresh UI with new data
    }
}