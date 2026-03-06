import React from 'react';
import { Truck, Car, Bike, AlertTriangle } from 'lucide-react';

const VehicleTypeIcon = ({ type }) => {
    switch (type?.toLowerCase()) {
        case 'bike':
        case 'scooter':
            return <Bike size={24} className="opacity-80" />;
        case 'car':
        case 'sedan':
        case 'suv':
            return <Car size={24} className="opacity-80" />;
        case 'auto':
        case 'rickshaw':
        default:
            return <Truck size={24} className="opacity-80" />; // Fallback icon
    }
};

const VehicleMonitor = ({ vehicles, onSelectVehicle }) => {
    return (
        <div className="glass-panel overflow-hidden flex flex-col h-full bg-slate-900/20 border-0 shadow-none">
            <div className="mb-4">
                <h2 className="text-lg font-bold text-white flex items-center gap-2">
                    Fleet Status Monitor
                </h2>
            </div>

            <div className="overflow-y-auto flex-1 min-h-0 pr-2 custom-scrollbar">
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {vehicles.map((v) => {
                        // Determine styling based on score
                        let statusColor = "emerald";
                        let statusText = "Optimal";
                        let insightTitle = "Predictive Insight";
                        let insightDesc = `Predictive ${v.issues?.[0] || 'System Check'} (Low)`;
                        let insightColor = "text-emerald-400";

                        if (v.score < 60) {
                            statusColor = "rose";
                            statusText = "Critical";
                            insightDesc = `Transmission Warning (High)`;
                            insightColor = "text-rose-400";
                        } else if (v.score < 80) {
                            statusColor = "amber";
                            statusText = "Service Due";
                            insightDesc = `Fuel Pump Efficiency Low\n(Service Due)`;
                            insightColor = "text-amber-400 whitespace-pre-line";
                        }

                        // Adjust explicit color mapping for Tailwind arbitrary classes to work dynamically
                        // We use predefined classes to ensure Tailwind compiles them
                        const cardBorders = {
                            emerald: "border-slate-800",
                            amber: "border-amber-500/30",
                            rose: "border-rose-500/30"
                        };

                        const iconBg = {
                            emerald: "bg-indigo-500/10 text-indigo-400",
                            amber: "bg-amber-500/10 text-amber-500",
                            rose: "bg-rose-500/10 text-rose-500"
                        };

                        const trendColor = {
                            emerald: "text-emerald-400",
                            amber: "text-amber-500",
                            rose: "text-rose-500"
                        };

                        const badgeClass = {
                            emerald: "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
                            amber: "bg-amber-500/10 text-amber-500 border border-amber-500/20",
                            rose: "bg-rose-500/10 text-rose-500 border border-rose-500/20"
                        };

                        const insightBox = {
                            emerald: "bg-slate-800/20 border-t border-slate-700/50",
                            amber: "bg-amber-950/20 border-t border-amber-900/30",
                            rose: "bg-rose-950/20 border-t border-rose-900/30"
                        };

                        return (
                            <div
                                key={v.id}
                                onClick={() => onSelectVehicle(v)}
                                className={`glass-panel border ${cardBorders[statusColor]} bg-slate-900/40 hover:bg-slate-800/50 transition-colors flex flex-col h-[180px] overflow-hidden cursor-pointer hover:-translate-y-0.5 transform duration-200 hover:shadow-lg`}
                            >
                                {/* Top Row: ID & Driver */}
                                <div className="p-3 pb-0 flex items-start gap-3">
                                    <div className={`w-10 h-10 rounded-lg flex items-center justify-center shrink-0 ${iconBg[statusColor]}`}>
                                        <VehicleTypeIcon type={v.info?.type} />
                                    </div>
                                    <div className="flex-1 min-w-0">
                                        <h3 className="text-white font-bold truncate tracking-wide">{v.id}</h3>
                                        <p className="text-xs text-slate-400 truncate">Driver - {v.info?.driver || 'Unknown'} • {v.info?.model}</p>
                                    </div>
                                </div>

                                {/* Middle Row: Score & Status */}
                                <div className="px-4 py-3 flex items-center justify-between mt-auto">
                                    <div className="flex items-center gap-1.5">
                                        <span className={`text-3xl font-bold ${trendColor[statusColor]}`}>
                                            {Math.round(v.score)}
                                        </span>
                                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" className={`ml-1 ${trendColor[statusColor]} mt-1`}>
                                            {v.score >= 80 ? (
                                                <path d="M7 17L17 7M17 7H9M17 7V15" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                                            ) : (
                                                <path d="M7 7L17 17M17 17H9M17 17V9" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                                            )}
                                        </svg>
                                    </div>
                                    <div className={`px-2 py-0.5 rounded text-xs font-semibold ${badgeClass[statusColor]}`}>
                                        {statusText}
                                    </div>
                                </div>

                                {/* Bottom Row: Predictive Insight */}
                                <div className={`px-4 py-2 flex items-end justify-between ${insightBox[statusColor]} mt-auto`}>
                                    <div>
                                        <p className="text-xs text-slate-400 mb-0.5">{insightTitle}</p>
                                        <p className={`text-xs font-medium leading-tight ${insightColor}`}>
                                            {insightDesc}
                                        </p>
                                    </div>
                                    <span className="text-slate-500 hover:text-blue-400 text-xs font-medium transition-colors mb-0.5 relative z-10 opacity-0 group-hover:opacity-100">
                                        Details &rarr;
                                    </span>
                                </div>
                            </div>
                        );
                    })}

                    {vehicles.length === 0 && (
                        <div className="col-span-full py-12 text-center text-slate-500 italic bg-slate-900/20 rounded-xl border border-dashed border-slate-700">
                            Waiting for fleet data...
                        </div>
                    )}
                </div>
            </div>

            <style jsx>{`
                .custom-scrollbar::-webkit-scrollbar {
                    width: 6px;
                }
                .custom-scrollbar::-webkit-scrollbar-track {
                    background: transparent;
                }
                .custom-scrollbar::-webkit-scrollbar-thumb {
                    background-color: rgba(51, 65, 85, 0.5);
                    border-radius: 20px;
                }
            `}</style>
        </div>
    );
};

export default VehicleMonitor;
