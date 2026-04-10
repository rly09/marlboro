import { createContext, useState, useEffect } from 'react';

const mockReports = [
  { id: 1, lat: 51.505, lng: -0.09, severity: 'High', status: 'Pending', img: 'https://images.unsplash.com/photo-1611284446314-60a58ac0deb9?auto=format&fit=crop&w=400&q=80', description: 'Large pile of plastic waste', aiInsight: 'Plastic waste detected - High priority' },
  { id: 2, lat: 51.51, lng: -0.1, severity: 'Medium', status: 'Pending', img: 'https://images.unsplash.com/photo-1530587191325-3db32d826c18?auto=format&fit=crop&w=400&q=80', description: 'Cardboard boxes dumped', aiInsight: 'Organic/Paper waste detected - Medium priority' },
  { id: 3, lat: 51.49, lng: -0.08, severity: 'Low', status: 'In Progress', img: 'https://images.unsplash.com/photo-1528323273322-d81458248d40?auto=format&fit=crop&w=400&q=80', description: 'A few wrappers and bottles', aiInsight: 'Low severity plastic' },
  { id: 4, lat: 51.52, lng: -0.12, severity: 'High', status: 'Pending', img: 'https://images.unsplash.com/photo-1588684534165-dbd86ec9e6f3?auto=format&fit=crop&w=400&q=80', description: 'Construction debris', aiInsight: 'Hazardous material detected - Critical' },
  { id: 5, lat: 51.495, lng: -0.11, severity: 'Low', status: 'Cleaned', img: 'https://images.unsplash.com/photo-1595278069441-2cf29f8005a4?auto=format&fit=crop&w=400&q=80', description: 'Cleaned up street', aiInsight: null }
];

export const AppContext = createContext();

export const AppProvider = ({ children }) => {
  const [reports, setReports] = useState(mockReports);
  const [userStats, setUserStats] = useState({ points: 250, streak: 3, badges: ['Eco Warrior', 'City Saver'] });

  const addReport = (report) => {
    setReports(prev => [...prev, { ...report, id: Date.now(), status: 'Pending' }]);
  };

  const claimReport = (id) => {
    setReports(prev => prev.map(r => r.id === id ? { ...r, status: 'In Progress' } : r));
    setUserStats(prev => ({ ...prev, points: prev.points + 10 }));
  };

  const completeReport = (id) => {
    setReports(prev => prev.map(r => r.id === id ? { ...r, status: 'Cleaned' } : r));
    setUserStats(prev => ({ ...prev, points: prev.points + 50 }));
  };

  return (
    <AppContext.Provider value={{ reports, userStats, addReport, claimReport, completeReport }}>
      {children}
    </AppContext.Provider>
  );
};
