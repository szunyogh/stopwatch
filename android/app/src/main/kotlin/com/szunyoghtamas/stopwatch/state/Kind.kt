package com.szunyoghtamas.stopwatch.state

import java.util.Locale

enum class Kind(val key: String) {
    STOPWATCH("stopwatch"),
    TIMER("timer");

    fun k(name: String) = if (this == STOPWATCH) name else "timer_$name"

    companion object {
        fun from(raw: String?) = entries.firstOrNull { it.key == raw } ?: STOPWATCH
    }
}

data class KindState(
    val kind: Kind,
    val isRunning: Boolean,
    val startedAtEpochMs: Long?,
    val accumulatedMs: Long,
    val totalMs: Long?,
) {
    fun valueMs(now: Long = System.currentTimeMillis()): Long {
        val since = if (isRunning && startedAtEpochMs != null) now - startedAtEpochMs else 0L
        return if (kind == Kind.TIMER) maxOf(0L, accumulatedMs - since) else accumulatedMs + since
    }

    val endAtEpochMs: Long?
        get() = if (kind == Kind.TIMER && isRunning && startedAtEpochMs != null) startedAtEpochMs + accumulatedMs else null
}

object TimeFormat {
    fun format(ms: Long, kind: Kind): String {
        val total = maxOf(0L, ms)
        val seconds = if (kind == Kind.TIMER) (total + 999) / 1000 else total / 1000
        val h = seconds / 3600
        val m = (seconds / 60) % 60
        val s = seconds % 60
        return if (h > 0) String.format(Locale.US, "%d:%02d:%02d", h, m, s) else String.format(Locale.US, "%02d:%02d", m, s)
    }
}