// Types partagés entre client et serveur

export type AssetSymbol = "GOLD" | "OIL" | "SP500" | "TSX";

export interface PlayerSummary {
  id: string;
  nickname: string;
  cash: number; // $
  netWorth: number; // $
}

export interface GameStateDTO {
  id: string;
  code: string;
  status: "lobby" | "running" | "ended";
  players: PlayerSummary[];
  serverTime: string; // ISO
}

export interface LeaderboardEntry {
  playerId: string;
  nickname: string;
  netWorth: number;
}

export interface HourlyTickEvent {
  gameId: string;
  at: string; // ISO
  leaderboard: LeaderboardEntry[];
}

export interface MarketPricePoint {
  symbol: AssetSymbol;
  price: number;
  at: string; // ISO
}
