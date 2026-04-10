import { useContext } from 'react';
import { motion } from 'framer-motion';
import { FileWarning, Clock, Leaf, Trophy, Map as MapIcon, ChevronRight } from 'lucide-react';
import { GlassCard } from '../components/GlassCard';
import { AppContext } from '../context/AppContext';
import { cn } from '../lib/utils';

export const DashboardScreen = () => {
  const { reports, userStats } = useContext(AppContext);

  const totalReports = reports.length;
  const inProgress = reports.filter(r => r.status === 'In Progress').length;
  const cleaned = reports.filter(r => r.status === 'Cleaned').length;

  const stats = [
    { label: 'Total Reports', value: totalReports, icon: FileWarning, color: 'text-blue-400', bg: 'bg-blue-500/10' },
    { label: 'In Progress', value: inProgress, icon: Clock, color: 'text-orange-400', bg: 'bg-orange-500/10' },
    { label: 'Cleaned Workspace', value: cleaned, icon: Leaf, color: 'text-emerald-400', bg: 'bg-emerald-500/10' },
  ];

  return (
    <div className="w-full min-h-screen bg-background pb-32 pt-12 px-4 md:px-8 max-w-4xl mx-auto">
      <header className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white tracking-tight">Dashboard</h1>
          <p className="text-white/50 mt-1">Hello, Eco Warrior 👋</p>
        </div>
        <div className="flex flex-col items-end gap-2">
          <div className="flex items-center gap-2 bg-emerald-500/10 border border-emerald-500/20 px-4 py-2 rounded-2xl shadow-[0_0_15px_rgba(16,185,129,0.2)]">
            <Trophy className="w-5 h-5 text-emerald-400" />
            <span className="text-emerald-400 font-semibold">{userStats.points} pts</span>
          </div>
          <div className="flex items-center gap-1.5 px-3 py-1 rounded-full bg-orange-500/10 border border-orange-500/30 shadow-[0_0_15px_rgba(249,115,22,0.2)]">
            <span className="animate-pulse">🔥</span>
            <span className="text-xs font-semibold text-orange-400">{userStats.streak} Days Streak</span>
          </div>
        </div>
      </header>

      {/* Hero Stats */}
      <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mb-8">
        {stats.map((stat, i) => {
          const Icon = stat.icon;
          return (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.1 }}
              className={cn("col-span-1", i === 2 && "col-span-2 md:col-span-1")}
            >
              <GlassCard className="h-full flex flex-col justify-between">
                <div className={cn("w-10 h-10 rounded-xl flex items-center justify-center mb-4", stat.bg)}>
                  <Icon className={cn("w-5 h-5", stat.color)} />
                </div>
                <div>
                  <motion.div 
                    initial={{ scale: 0.5 }}
                    animate={{ scale: 1 }}
                    className="text-3xl font-bold text-white mb-1"
                  >
                    {stat.value}
                  </motion.div>
                  <p className="text-sm text-white/60">{stat.label}</p>
                </div>
              </GlassCard>
            </motion.div>
          );
        })}
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        {/* Leaderboard Section */}
        <motion.div id="leaderboard" initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.3 }}>
          <h2 className="text-xl font-semibold text-white mb-4 flex items-center gap-2">
            <Trophy className="w-5 h-5 text-yellow-400" />
            Local Leaderboard
          </h2>
          <GlassCard className="p-0 overflow-hidden">
            <div className="divide-y divide-white/5">
              {[
                { name: 'Sarah M.', points: 1250, badge: 'Eco Warrior', rank: 1 },
                { name: 'You', points: userStats.points, badge: userStats.badges[0], rank: 2, isMe: true },
                { name: 'David K.', points: 840, badge: 'City Saver', rank: 3 },
                { name: 'Emma W.', points: 620, badge: 'Scout', rank: 4 },
              ].map((user) => (
                <div key={user.name} className={cn("flex items-center justify-between p-4 transition-colors", user.isMe && "bg-emerald-500/5")}>
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center text-sm font-bold text-white/50">
                      #{user.rank}
                    </div>
                    <div>
                      <p className={cn("font-medium", user.isMe ? "text-emerald-400" : "text-white/90")}>{user.name}</p>
                      <p className="text-xs text-white/50 flex items-center gap-1">
                        {user.badge === 'Eco Warrior' && <span className="text-yellow-400 px-1.5 py-0.5 bg-yellow-400/10 rounded-full border border-yellow-400/20">{user.badge}</span>}
                        {user.badge !== 'Eco Warrior' && <span className="text-blue-400 px-1.5 py-0.5 bg-blue-400/10 rounded-full border border-blue-400/20">{user.badge}</span>}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-bold text-white">{user.points}</p>
                    <p className="text-xs text-white/50">pts</p>
                  </div>
                </div>
              ))}
            </div>
          </GlassCard>
        </motion.div>

        {/* Predictive AI Heatmap Alert */}
        <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.4 }}>
          <h2 className="text-xl font-semibold text-white mb-4 flex items-center gap-2">
            <MapIcon className="w-5 h-5 text-blue-400" />
            Predictive Insights
          </h2>
          <GlassCard className="relative overflow-hidden group border-red-500/20 shadow-[0_0_20px_rgba(239,68,68,0.1)]">
            <div className="absolute top-0 right-0 p-4">
              <span className="flex h-3 w-3 relative">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-3 w-3 bg-red-500"></span>
              </span>
            </div>
            
            <div className="mb-4">
              <p className="text-red-400 font-semibold mb-1">High Risk Zone (Next 24h)</p>
              <p className="text-sm text-white/60">Based on past dumping patterns, Area 51 has a 85% chance of becoming a critical dumping site.</p>
            </div>

            <div className="h-32 rounded-xl bg-white/5 border border-white/10 mb-4 overflow-hidden relative flex items-center justify-center">
               <div className="absolute inset-0 opacity-30 bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-red-500 via-transparent to-transparent"></div>
               <MapIcon className="w-12 h-12 text-white/20" />
            </div>

            <button className="w-full flex items-center justify-center gap-2 py-2 rounded-xl bg-white/5 hover:bg-white/10 text-white text-sm font-medium transition-colors">
              View Route <ChevronRight className="w-4 h-4" />
            </button>
          </GlassCard>
        </motion.div>
      </div>
    </div>
  );
};
