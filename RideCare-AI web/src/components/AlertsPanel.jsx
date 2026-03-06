import React from 'react';
import { AlertCircle, AlertTriangle, Bell } from 'lucide-react';

const AlertItem = ({ alert }) => {
    const isCritical = alert.type === 'Critical';
    const Icon = isCritical ? AlertCircle : AlertTriangle;

    // Richer styles to match mock
    const colorClass = isCritical
        ? 'bg-[#3b1219] border-rose-900/50 text-rose-300'
        : 'bg-[#362712] border-amber-900/50 text-amber-300';

    const badgeClass = isCritical
        ? 'bg-rose-500/20 text-rose-400 border-rose-500/20'
        : 'bg-amber-500/20 text-amber-500 border-amber-500/20';

    return (
        <div className={`p-3 rounded-2xl border flex gap-3 ${colorClass} mx-1`}>
            <Icon className="shrink-0 mt-0.5" size={18} />
            <div className="flex-1 min-w-0">
                <div className="flex justify-between items-start mb-0.5">
                    <span className="font-bold text-sm truncate">{alert.type}</span>
                    <span className={`text-[10px] px-2 py-0.5 rounded-md border ${badgeClass}`}>{alert.type}</span>
                </div>
                <p className="text-sm font-semibold text-slate-200 truncate">{alert.vehicleId} - {alert.message}</p>
                <p className="text-xs opacity-80 mt-1 truncate">
                    All active alerts right now. {alert.type === 'Critical' ? 'Critical.' : 'Low.'}
                </p>
            </div>
        </div>
    );
};

const AlertsPanel = ({ vehicles }) => {
    const activeAlerts = vehicles
        .filter(v => v.score < 80)
        .map(v => {
            const type = v.score < 60 ? 'Critical' : 'Attention';
            return {
                id: `${v.id}-${type}`,
                vehicleId: v.id,
                type: type,
                message: v.prediction || (type === 'Critical' ? 'Brake Wear Predicted Critical' : 'Oil Life Low'),
                timestamp: v.lastUpdated || Date.now(),
                score: v.score
            };
        })
        .sort((a, b) => b.timestamp - a.timestamp)
        .slice(0, 5);

    return (
        <div className="glass-panel h-full flex flex-col bg-slate-900/40 border border-slate-700/50 relative overflow-hidden">
            {/* Subtle bg glow */}
            <div className="absolute top-0 right-0 w-64 h-64 bg-blue-500/5 rounded-full blur-3xl -z-10 translate-x-1/3 -translate-y-1/3"></div>

            <div className="p-4 border-b border-slate-800/80 flex items-center justify-between">
                <h3 className="text-lg font-bold text-white flex items-center gap-2">
                    <Bell size={20} className="text-indigo-400" />
                    Active Alerts
                </h3>
            </div>

            <div className="p-4 flex-1 overflow-y-auto space-y-3 custom-scrollbar">
                {activeAlerts.length > 0 ? (
                    activeAlerts.map(alert => <AlertItem key={alert.id} alert={alert} />)
                ) : (
                    <div className="h-full flex flex-col justify-center items-center text-slate-500 opacity-70">
                        <Bell size={36} className="mb-2 opacity-50" />
                        <p className="text-sm font-medium">No active alerts.</p>
                    </div>
                )}
            </div>
        </div>
    );
};

export default AlertsPanel;
