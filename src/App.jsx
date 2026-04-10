import { useState } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AppProvider } from './context/AppContext';
import { Navbar } from './components/Navbar';
import { MapScreen } from './pages/MapScreen';
import { DashboardScreen } from './pages/DashboardScreen';
import { ReportModal } from './components/ReportModal';

function App() {
  const [isReportOpen, setIsReportOpen] = useState(false);

  return (
    <AppProvider>
      <Router>
        <div className="bg-background min-h-screen text-white font-sans selection:bg-emerald-500/30">
          <Routes>
            <Route path="/" element={<MapScreen />} />
            <Route path="/dashboard" element={<DashboardScreen />} />
          </Routes>
          
          <Navbar onOpenReport={() => setIsReportOpen(true)} />
          <ReportModal isOpen={isReportOpen} onClose={() => setIsReportOpen(false)} />
        </div>
      </Router>
    </AppProvider>
  );
}

export default App;
