import { Link, useLocation } from 'react-router-dom';
import { Map, BarChart3, Trophy, Plus } from 'lucide-react';
import { cn } from '../lib/utils';
import { motion } from 'framer-motion';

export const Navbar = ({ onOpenReport }) => {
  const location = useLocation();

  const navItems = [
    { name: 'Map', path: '/', icon: Map },
    { name: 'Dashboard', path: '/dashboard', icon: BarChart3 },
    { name: 'Leaderboard', path: '/dashboard#leaderboard', icon: Trophy },
  ];

  return (
    <>
      <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-[400] flex items-center justify-center pointer-events-auto">
        <div className="bg-black/40 backdrop-blur-xl border border-white/10 rounded-full px-6 py-3 flex items-center gap-8 shadow-[0_0_20px_rgba(0,0,0,0.5)]">
          {navItems.map((item) => {
            const isActive = location.pathname === item.path;
            const Icon = item.icon;
            return (
              <Link key={item.name} to={item.path} className="relative flex flex-col items-center group">
                <Icon className={cn("w-6 h-6 transition-colors duration-300", isActive ? "text-emerald-400" : "text-white/50 group-hover:text-white/80")} />
                {isActive && (
                  <motion.div layoutId="nav-indicator" className="absolute -bottom-2 w-1 h-1 rounded-full bg-emerald-400 shadow-[0_0_10px_rgba(16,185,129,0.8)]" />
                )}
              </Link>
            );
          })}
        </div>
      </div>

      <button 
        onClick={onOpenReport}
        className="fixed bottom-6 right-6 z-[400] flex items-center justify-center w-14 h-14 rounded-full bg-gradient-to-r from-emerald-500 to-blue-500 shadow-[0_0_30px_rgba(16,185,129,0.5)] hover:scale-110 transition-transform duration-300 pointer-events-auto group animate-[pulse_2s_ease-in-out_infinite]"
      >
        <Plus className="w-8 h-8 text-white group-hover:rotate-90 transition-transform duration-300" />
      </button>
    </>
  );
};
