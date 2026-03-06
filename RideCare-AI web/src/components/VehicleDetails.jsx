import React from 'react';
import { X, Cpu, Activity, Thermometer, Battery, ShieldAlert, Sparkles, Navigation } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const DetailItem = ({ icon: Icon, label, value, unit, isWarning }) => (
    <div className={`p-4 rounded-xl border ${isWarning ? 'bg-rose-500/10 border-rose-500/20' : 'bg-slate-800/50 border-slate-700/50'}`}>
        <div className="flex items-center gap-2 mb-2">
            <Icon size={16} className={isWarning ? 'text-rose-400' : 'text-slate-400'} />
            <span className="text-xs font-medium text-slate-400 uppercase tracking-wider">{label}</span>
        </div>
        <div className="flex items-baseline gap-1">
            <span className={`text-2xl font-bold ${isWarning ? 'text-rose-400' : 'text-slate-100'}`}>{value}</span>
            <span className="text-sm font-medium text-slate-500">{unit}</span>
        </div>
    </div>
);

const VehicleDetails = ({ vehicle, onClose, timeSeriesData }) => {
    if (!vehicle) return null;

    const isCritical = vehicle.score < 60;

    // Format data for chart
    const chartData = timeSeriesData[vehicle.id] || [];

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm animate-in fade-in duration-200">
            <div className="glass-panel w-full max-w-4xl max-h-[90vh] flex flex-col shadow-2xl overflow-hidden border-slate-700">

                {/* Header */}
                <div className="flex items-center justify-between p-6 border-b border-slate-700/50 bg-slate-800/40">
                    <div className="flex items-center gap-4">
                        <div className={`w-14 h-14 rounded-full flex items-center justify-center border-4 ${isCritical ? 'bg-rose-500/20 border-rose-500/30 text-rose-400' : 'bg-emerald-400/20 border-emerald-400/30 text-emerald-400'}`}>
                            <span className="text-2xl font-bold">{Math.round(vehicle.score)}</span>
                        </div>
                        <div>
                            <h2 className="text-2xl font-bold text-white mb-1 flex items-center gap-3">
                                {vehicle.id} <span className="text-sm font-normal text-slate-400 px-2 py-0.5 rounded-md bg-slate-800 border border-slate-700">{vehicle.info?.type}</span>
                            </h2>
                            <p className="text-sm text-slate-400 flex items-center gap-2">
                                <Navigation size={14} /> Driver: {vehicle.info?.driver} • {vehicle.info?.model}
                            </p>
                        </div>
                    </div>
                    <button
                        onClick={onClose}
                        className="p-2 text-slate-400 hover:text-white hover:bg-slate-700 rounded-full transition-colors"
                    >
                        <X size={24} />
                    </button>
                </div>

                {/* Content */}
                <div className="flex-1 overflow-y-auto p-6 space-y-6 [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none]">

                    {/* OpenAI Prediction Banner */}
                    <div className="p-4 rounded-xl border border-indigo-500/30 bg-indigo-500/10 flex items-start gap-4">
                        <div className="p-2 bg-indigo-500/20 rounded-lg text-indigo-400 mt-1">
                            <Sparkles size={24} />
                        </div>
                        <div>
                            <h4 className="text-sm font-semibold text-indigo-300 mb-1 uppercase tracking-wider">RideCare AI Analysis</h4>
                            <p className="text-lg text-indigo-100 font-medium leading-relaxed">
                                "{vehicle.prediction}"
                            </p>
                            {vehicle.issues && vehicle.issues.length > 0 && (
                                <div className="mt-3 flex flex-wrap gap-2">
                                    {vehicle.issues.map((issue, i) => (
                                        <span key={i} className="inline-flex items-center px-2.5 py-1 rounded text-xs font-medium bg-rose-500/20 text-rose-300 border border-rose-500/20">
                                            <ShieldAlert size={12} className="mr-1.5" />
                                            {issue}
                                        </span>
                                    ))}
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Telemetry Grid */}
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                        <DetailItem
                            icon={Thermometer}
                            label="Engine Temp"
                            value={vehicle.temperature.toFixed(1)}
                            unit="°C"
                            isWarning={vehicle.temperature > 95}
                        />
                        <DetailItem
                            icon={Battery}
                            label="Battery"
                            value={vehicle.voltage.toFixed(2)}
                            unit="V"
                            isWarning={vehicle.voltage < 12.0}
                        />
                        <DetailItem
                            icon={Activity}
                            label="Vibration"
                            value={vehicle.vibration.toFixed(1)}
                            unit="hz"
                            isWarning={vehicle.vibration - (vehicle.baseVib || 10) > 10}
                        />
                        <DetailItem
                            icon={Thermometer}
                            label="Fuel Eff."
                            value={vehicle.fuelEfficiency?.toFixed(1) || '--'}
                            unit="km/l"
                            isWarning={(vehicle.baseFuel || 20) - (vehicle.fuelEfficiency || 20) > 4}
                        />
                    </div>

                    {/* Chart Area */}
                    <div className="p-5 rounded-xl border border-slate-700/50 bg-slate-800/20 h-72">
                        <div className="flex justify-between items-center mb-4">
                            <h3 className="text-sm font-semibold text-slate-300">Health Score Trend (Last 5 mins)</h3>
                            <div className="flex items-center gap-2">
                                <span className="flex h-2 w-2 rounded-full bg-emerald-400"></span>
                                <span className="text-xs text-slate-400">Live Updates</span>
                            </div>
                        </div>

                        <div className="h-48 w-full mt-4">
                            {chartData.length > 1 ? (
                                <ResponsiveContainer width="100%" height="100%">
                                    <LineChart data={chartData}>
                                        <CartesianGrid strokeDasharray="3 3" stroke="#334155" opacity={0.5} />
                                        <XAxis
                                            dataKey="time"
                                            stroke="#64748b"
                                            fontSize={11}
                                            tickLine={false}
                                            axisLine={false}
                                        />
                                        <YAxis
                                            domain={[0, 100]}
                                            stroke="#64748b"
                                            fontSize={11}
                                            tickLine={false}
                                            axisLine={false}
                                        />
                                        <Tooltip
                                            contentStyle={{ backgroundColor: '#0f172a', borderColor: '#334155', borderRadius: '8px' }}
                                            itemStyle={{ color: '#e2e8f0' }}
                                        />
                                        <Line
                                            type="monotone"
                                            dataKey="score"
                                            stroke="#38bdf8"
                                            strokeWidth={3}
                                            dot={false}
                                            activeDot={{ r: 6, fill: '#38bdf8', stroke: '#0f172a', strokeWidth: 2 }}
                                        />
                                    </LineChart>
                                </ResponsiveContainer>
                            ) : (
                                <div className="w-full h-full flex flex-col items-center justify-center text-slate-500">
                                    <Activity size={32} className="mb-2 opacity-50 animate-pulse" />
                                    <p className="text-sm">Gathering telemetry data...</p>
                                </div>
                            )}
                        </div>
                    </div>

                </div>
            </div>
        </div>
    );
};

export default VehicleDetails;
