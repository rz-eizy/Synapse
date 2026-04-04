import { BrowserRouter, Routes, Route} from "react-router-dom";

//Paginas Importadas
import { LoginPage } from "./pages/LoginPage/LoginPage";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />

      </Routes>
    </BrowserRouter>
  );
}

export default App;

