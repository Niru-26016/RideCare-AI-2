import React, { useState, useEffect } from 'react';
import { collection, onSnapshot, query, orderBy } from 'firebase/firestore';
import { ShieldCheck, Activity, Zap } from 'lucide-react';
import { db } from './config/firebase';
import FleetControlCenter from './components/FleetControlCenter';
import VehicleMonitor from './components/VehicleMonitor';
import VehicleDetails from './components/VehicleDetails';
import AlertsPanel from './components/AlertsPanel';

const App = () => {
  const [vehicles, setVehicles] = useState([]);
  const [selectedVehicle, setSelectedVehicle] = useState(null);
  const [timeSeriesData, setTimeSeriesData] = useState({});

  // Load Data
  useEffect(() => {
    // Listen to firestore updates
    const q = query(collection(db, 'vehicles'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const vData = [];
      const now = new Date().toLocaleTimeString('en-US', { hour12: false, hour: "numeric", minute: "numeric", second: "numeric" });

      snapshot.forEach((doc) => {
        const data = doc.data();
        vData.push({ id: doc.id, ...data });

        // Update time series map for charts
        setTimeSeriesData(prev => {
          let vHistory = prev[doc.id];
          if (!vHistory) {
            // Generate 5 dummy past points so graph renders immediately
            vHistory = Array.from({ length: 5 }).map((_, i) => {
              const pastTime = new Date(Date.now() - (5 - i) * 5000);
              return {
                time: pastTime.toLocaleTimeString('en-US', { hour12: false, hour: "numeric", minute: "numeric", second: "numeric" }),
                score: data.score
              };
            });
          }
          // Keep last 15 data points
          const newHistory = [...vHistory, { time: now, score: data.score }].slice(-15);
          return { ...prev, [doc.id]: newHistory };
        });
      });

      // Sort by ID naturally
      vData.sort((a, b) => a.id.localeCompare(b.id));
      setVehicles(vData);
    });

    return () => {
      unsubscribe();
    };
  }, []);



  const exportToCSV = () => {
    if (!vehicles.length) return;

    // Define CSV headers
    const headers = ['Vehicle ID', 'Driver', 'Type', 'Model', 'Health Score', 'Status', 'Issues', 'Last Updated'];

    // Map vehicle data to CSV rows
    const csvRows = vehicles.map(v => {
      return [
        v.id,
        v.info?.driver || 'Unknown',
        v.info?.type || 'Unknown',
        v.info?.model || 'Unknown',
        Math.round(v.score),
        v.state,
        (v.issues || []).join('; ') || 'None',
        new Date(v.lastUpdated || Date.now()).toISOString()
      ].map(val => `"${val}"`).join(','); // Escape values with quotes
    });

    // Combine headers and rows
    const csvContent = [headers.join(','), ...csvRows].join('\n');

    // Create blob and download link
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', `ridecare_fleet_export_${new Date().toISOString().split('T')[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  return (
    <div className="h-screen bg-slate-950 text-slate-100 py-4 px-4 sm:px-6 lg:px-8 selection:bg-indigo-500/30 flex flex-col overflow-hidden">
      {/* Header */}
      <header className="w-full flex flex-col md:flex-row md:items-center justify-between mb-4 pb-4 border-b border-slate-800/60 shrink-0">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-indigo-500 rounded-xl flex items-center justify-center shadow-lg shadow-indigo-500/20">
            <ShieldCheck size={24} className="text-white" />
          </div>
          <div>
            <h1 className="text-xl font-extrabold text-white tracking-tight flex items-center gap-1">
              RideCare <span className="text-indigo-400 bg-indigo-500/10 px-1.5 py-0.5 rounded-md ml-1 text-sm">AI</span>
            </h1>
            <p className="text-slate-400 text-xs font-medium">
              Predictive Vehicle Health Dashboard
            </p>
          </div>
        </div>

        <div className="mt-4 md:mt-0 flex flex-wrap items-center gap-3 justify-end">
          <button
            onClick={exportToCSV}
            className="flex items-center justify-center gap-2 px-4 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 rounded-xl text-sm font-semibold shadow-sm transition-colors"
            title="Export Fleet Data to CSV"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" /><polyline points="7 10 12 15 17 10" /><line x1="12" y1="15" x2="12" y2="3" /></svg>
            Export
          </button>

          <div className="flex items-center gap-2 px-3 py-1.5 bg-slate-900/50 border border-slate-800 rounded-full">
            <span className="relative flex h-2.5 w-2.5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
            </span>
            <span className="text-xs font-medium text-slate-300">Live Traffic</span>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="w-full flex-1 flex flex-col min-h-0 space-y-6">

        {/* Dashboard Grid */}
        <section className="grid grid-cols-1 xl:grid-cols-12 gap-6 flex-1 min-h-0">

          {/* Left Block: List (takes 8 cols on xl) */}
          <div className="xl:col-span-8 flex flex-col min-h-0">
            <div className="shrink-0 mb-6">
              <FleetControlCenter vehicles={vehicles} />
            </div>

            <div className="flex-1 min-h-0">
              <VehicleMonitor
                vehicles={vehicles}
                onSelectVehicle={setSelectedVehicle}
              />
            </div>
          </div>

          {/* Right Block: Alerts (takes 4 cols on xl) */}
          <div className="xl:col-span-4 flex flex-col min-h-0">
            <div className="flex-1 min-h-0">
              <AlertsPanel vehicles={vehicles} />
            </div>
          </div>

        </section>

      </main>

      {/* Overlays */}
      {selectedVehicle && (
        <VehicleDetails
          vehicle={selectedVehicle}
          timeSeriesData={timeSeriesData}
          onClose={() => setSelectedVehicle(null)}
        />
      )}

    </div>
  );
};

export default App;
