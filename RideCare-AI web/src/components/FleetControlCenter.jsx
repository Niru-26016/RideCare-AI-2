import React from 'react';
import { Activity, AlertTriangle, TrendingUp, TrendingDown } from 'lucide-react';

const FleetControlCenter = ({ vehicles }) => {
    const total = vehicles.length;

    // Calculate overall health score average
    const avgScore = total > 0
        ? Math.round(vehicles.reduce((sum, v) => sum + v.score, 0) / total)
        : 0;

    const healthy = vehicles.filter(v => v.score >= 80).length;
    const attention = vehicles.filter(v => v.score >= 60 && v.score < 80).length;
    const critical = vehicles.filter(v => v.score < 60).length;

    // SVG Circular Progress Math
    const radius = 38;
    const circumference = 2 * Math.PI * radius;
    const strokeDashoffset = circumference - (avgScore / 100) * circumference;

    return (
        <div className="flex flex-col md:flex-row gap-4 h-full">

            {/* Left Block: Fleet Health Index */}
            <div className="glass-panel p-6 lg:p-8 flex-1 relative overflow-hidden flex items-center justify-between border border-slate-700/50 bg-slate-900/40">
                {/* Background glow */}
                <div className="absolute top-1/2 left-0 -translate-y-1/2 w-48 h-48 bg-emerald-500/5 rounded-full blur-3xl -z-10"></div>

                <div className="flex items-center gap-8">
                    {/* Circular Progress */}
                    <div className="relative w-32 h-32 flex items-center justify-center shrink-0">
                        {/* Background ring */}
                        <svg className="w-full h-full -rotate-90 transform" viewBox="0 0 100 100">
                            <circle
                                cx="50"
                                cy="50"
                                r={radius}
                                className="stroke-slate-800"
                                strokeWidth="8"
                                fill="none"
                            />
                            {/* Value ring */}
                            <circle
                                cx="50"
                                cy="50"
                                r={radius}
                                className="stroke-emerald-400 transition-all duration-1000 ease-out"
                                strokeWidth="8"
                                fill="none"
                                strokeLinecap="round"
                                style={{
                                    strokeDasharray: circumference,
                                    strokeDashoffset: strokeDashoffset
                                }}
                            />
                        </svg>
                        {/* Inner text */}
                        <div className="absolute inset-0 flex items-center justify-center">
                            <span className="text-3xl font-bold text-white">{avgScore}%</span>
                        </div>
                    </div>

                    <div className="flex flex-col">
                        <h2 className="text-slate-200 font-bold text-xl mb-1">Fleet Health Index</h2>
                        <div className="flex items-end gap-2 text-emerald-400 mb-1">
                            <span className="text-4xl font-extrabold leading-none">{avgScore}%</span>
                            <TrendingUp size={24} className="mb-1" />
                        </div>
                        <p className="text-emerald-400/80 text-base font-medium">Optimal</p>
                    </div>
                </div>

                {/* Decorative Trend Line (Mocked for visual) */}
                <div className="hidden sm:block w-32 h-16 ml-4 opacity-70">
                    <svg viewBox="0 0 100 40" className="w-full h-full preserve-3d" preserveAspectRatio="none">
                        <path
                            d="M 0 35 Q 10 20, 20 25 T 40 15 T 60 20 T 80 5 T 100 0"
                            fill="none"
                            stroke="url(#trendGradient)"
                            strokeWidth="2.5"
                            strokeLinecap="round"
                            className="drop-shadow-[0_4px_6px_rgba(52,211,153,0.3)]"
                        />
                        <defs>
                            <linearGradient id="trendGradient" x1="0" y1="0" x2="1" y2="0">
                                <stop offset="0%" stopColor="#10b981" stopOpacity="0.2" />
                                <stop offset="50%" stopColor="#34d399" stopOpacity="0.8" />
                                <stop offset="100%" stopColor="#6ee7b7" stopOpacity="1" />
                            </linearGradient>
                        </defs>
                    </svg>
                </div>
            </div>

            {/* Right Block: Stats Summaries */}
            <div className="glass-panel p-5 flex-1 flex divide-x divide-slate-800/80 border border-slate-700/50 bg-slate-900/30">
                {/* Healthy Fleet Status */}
                <div className="flex-1 px-4 flex flex-col justify-center">
                    <p className="text-slate-300 text-sm mb-1 font-medium">Healthy Fleet</p>
                    <div className="flex items-baseline gap-1">
                        <span className="text-3xl font-bold text-emerald-400">{healthy}</span>
                        <span className="text-slate-500 text-sm font-medium">/{total}</span>
                    </div>
                    <p className="text-emerald-400/70 text-xs mt-1">Optimal</p>
                </div>

                {/* Attention Status */}
                <div className="flex-1 px-4 flex flex-col justify-center">
                    <p className="text-slate-300 text-sm mb-1 font-medium">Attention Req.</p>
                    <span className="text-3xl font-bold text-amber-400">{attention}</span>
                    <p className="text-amber-400/70 text-xs mt-1">Predictive</p>
                </div>

                {/* Critical Status */}
                <div className="flex-1 px-4 flex flex-col justify-center">
                    <p className="text-slate-300 text-sm mb-1 font-medium">Critical Issues</p>
                    <span className="text-3xl font-bold text-rose-500">{critical}</span>
                    <p className="text-rose-500/70 text-xs mt-1">Critical</p>
                </div>
            </div>

        </div>
    );
};

export default FleetControlCenter;
