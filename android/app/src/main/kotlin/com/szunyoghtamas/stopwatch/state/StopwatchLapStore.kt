
package com.szunyoghtamas.stopwatch.state
 
import android.content.Context
import androidx.core.content.edit

object StopwatchLapStore {
    private const val PREFS_NAME = "stopwatch_laps"
    private const val KEY_LAPS = "laps"
 
    private fun prefs(context: Context) =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
 
    fun get(context: Context): String? = prefs(context).getString(KEY_LAPS, null)
 
    fun save(context: Context, json: String) {
        prefs(context).edit { putString(KEY_LAPS, json) }
    }
 
    fun clear(context: Context) {
        prefs(context).edit { remove(KEY_LAPS) }
    }
}