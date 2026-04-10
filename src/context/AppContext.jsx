import { createContext, useState, useEffect } from 'react';

export const AppContext = createContext();

export const AppProvider = ({ children }) => {
  const [reports, setReports] = useState([]);
  const [userStats, setUserStats] = useState({ points: 0, streak: 0, badges: [] });

  const fetchData = async () => {
    try {
      const reportsRes = await fetch('/api/reports');
      const reportsData = await reportsRes.json();
      setReports(reportsData);

      const statsRes = await fetch('/api/user/stats');
      const statsData = await statsRes.json();
      setUserStats(statsData);
    } catch (err) {
      console.error("Failed to fetch data:", err);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const addReport = async (reportData) => {
    try {
      const formData = new FormData();
      formData.append('lat', reportData.lat);
      formData.append('lng', reportData.lng);
      formData.append('description', reportData.description);
      
      // Use the actual file object if provided
      if (reportData.file) {
        formData.append('file', reportData.file);
      } else {
        // Fallback for demo if no file
        const dummyBlob = new Blob(['dummy content'], { type: 'image/jpeg' });
        formData.append('file', dummyBlob, 'upload.jpg');
      }

      const res = await fetch('/api/reports', {
        method: 'POST',
        body: formData,
      });
      const newReport = await res.json();
      setReports(prev => [...prev, newReport]);
    } catch (err) {
      console.error("Failed to add report:", err);
    }
  };

  const claimReport = async (id) => {
    try {
      await fetch(`/api/reports/${id}/claim`, { method: 'PUT' });
      // Optimistic update
      setReports(prev => prev.map(r => r.id === id ? { ...r, status: 'In Progress' } : r));
      setUserStats(prev => ({ ...prev, points: prev.points + 10 }));
    } catch (err) {
      console.error("Failed to claim report:", err);
    }
  };

  const completeReport = async (id) => {
    try {
      await fetch(`/api/reports/${id}/complete`, { method: 'PUT' });
      // Optimistic update
      setReports(prev => prev.map(r => r.id === id ? { ...r, status: 'Cleaned' } : r));
      setUserStats(prev => ({ ...prev, points: prev.points + 50 }));
    } catch (err) {
      console.error("Failed to complete report:", err);
    }
  };

  return (
    <AppContext.Provider value={{ reports, userStats, addReport, claimReport, completeReport }}>
      {children}
    </AppContext.Provider>
  );
};
