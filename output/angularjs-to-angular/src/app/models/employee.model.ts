export interface Employee {
  id: number;
  name: string;
  title: string;
  department: string;
  location: string;
  active: boolean;
  searchIndex?: string;
}
